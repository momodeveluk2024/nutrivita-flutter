package db

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type Reminder struct {
	ID        uuid.UUID `json:"id"`
	UserID    uuid.UUID `json:"user_id"`
	Title     string    `json:"title"`
	Body      *string   `json:"body,omitempty"`
	RemindAt  time.Time `json:"remind_at"`
	Timezone  string    `json:"timezone"`
	Enabled   bool      `json:"enabled"`
	CreatedAt time.Time `json:"created_at"`
}

type CreateReminderParams struct {
	ID       uuid.UUID
	UserID   uuid.UUID
	Title    string
	Body     *string
	RemindAt time.Time
	Timezone string
	Enabled  bool
}

type Recommendation struct {
	Code     string    `json:"code"`
	Name     string    `json:"name"`
	Message  string    `json:"message"`
	Percent  *float64  `json:"percent,omitempty"`
	FoodID   uuid.UUID `json:"food_id"`
	FoodName string    `json:"food_name"`
}

func (s *Store) AddFavorite(ctx context.Context, userID, foodID uuid.UUID) error {
	_, err := s.pool.Exec(ctx, `
		INSERT INTO favorites (user_id, food_id)
		VALUES ($1, $2)
		ON CONFLICT (user_id, food_id) DO NOTHING
	`, userID, foodID)
	return err
}

func (s *Store) RemoveFavorite(ctx context.Context, userID, foodID uuid.UUID) error {
	_, err := s.pool.Exec(ctx, `DELETE FROM favorites WHERE user_id = $1 AND food_id = $2`, userID, foodID)
	return err
}

func (s *Store) ListFavorites(ctx context.Context, userID uuid.UUID) ([]FoodSummary, error) {
	rows, err := s.pool.Query(ctx, `
		SELECT
			f.id,
			f.name,
			f.brand,
			f.category,
			f.serving_size_g::float8,
			f.verified,
			COALESCE(array_agg(n.code ORDER BY n.code) FILTER (WHERE n.code IS NOT NULL), '{}')::text[] AS nutrient_codes
		FROM favorites fav
		JOIN foods f ON f.id = fav.food_id
		LEFT JOIN food_nutrients fn ON fn.food_id = f.id
		LEFT JOIN nutrients n ON n.id = fn.nutrient_id
		WHERE fav.user_id = $1 AND f.deleted_at IS NULL
		GROUP BY f.id, fav.created_at
		ORDER BY fav.created_at DESC
	`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	foods := []FoodSummary{}
	for rows.Next() {
		var food FoodSummary
		if err := rows.Scan(&food.ID, &food.Name, &food.Brand, &food.Category, &food.ServingSizeG, &food.Verified, &food.Nutrients); err != nil {
			return nil, err
		}
		foods = append(foods, food)
	}
	return foods, rows.Err()
}

func (s *Store) CreateReminder(ctx context.Context, params CreateReminderParams) (Reminder, error) {
	var reminder Reminder
	err := s.pool.QueryRow(ctx, `
		INSERT INTO reminders (id, user_id, title, body, remind_at, timezone, enabled)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, user_id, title, body, remind_at, timezone, enabled, created_at
	`, params.ID, params.UserID, params.Title, params.Body, params.RemindAt, params.Timezone, params.Enabled).Scan(
		&reminder.ID,
		&reminder.UserID,
		&reminder.Title,
		&reminder.Body,
		&reminder.RemindAt,
		&reminder.Timezone,
		&reminder.Enabled,
		&reminder.CreatedAt,
	)
	return reminder, err
}

func (s *Store) ListReminders(ctx context.Context, userID uuid.UUID) ([]Reminder, error) {
	rows, err := s.pool.Query(ctx, `
		SELECT id, user_id, title, body, remind_at, timezone, enabled, created_at
		FROM reminders
		WHERE user_id = $1
		ORDER BY remind_at ASC
	`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	reminders := []Reminder{}
	for rows.Next() {
		var reminder Reminder
		if err := rows.Scan(&reminder.ID, &reminder.UserID, &reminder.Title, &reminder.Body, &reminder.RemindAt, &reminder.Timezone, &reminder.Enabled, &reminder.CreatedAt); err != nil {
			return nil, err
		}
		reminders = append(reminders, reminder)
	}
	return reminders, rows.Err()
}

func (s *Store) DeleteReminder(ctx context.Context, userID, reminderID uuid.UUID) error {
	_, err := s.pool.Exec(ctx, `DELETE FROM reminders WHERE user_id = $1 AND id = $2`, userID, reminderID)
	return err
}

func (s *Store) GetRecommendations(ctx context.Context, userID uuid.UUID, date string) ([]Recommendation, error) {
	rows, err := s.pool.Query(ctx, `
		WITH low AS (
			SELECT
				n.id AS nutrient_id,
				n.code,
				n.name,
				COALESCE((t.amount / d.amount) * 100, 0)::float8 AS percent
			FROM nutrients n
			JOIN user_profiles p ON p.user_id = $1
			LEFT JOIN LATERAL (
				SELECT amount
				FROM dri_values d
				WHERE d.nutrient_id = n.id
				  AND d.life_stage IN ('adult', CASE WHEN p.pregnancy_status = 'pregnant' THEN 'pregnancy' ELSE 'adult' END)
				  AND (d.sex = p.sex OR d.sex IS NULL)
				ORDER BY
				  CASE WHEN d.life_stage = CASE WHEN p.pregnancy_status = 'pregnant' THEN 'pregnancy' ELSE 'adult' END THEN 0 ELSE 1 END,
				  CASE WHEN d.sex = p.sex THEN 0 ELSE 1 END
				LIMIT 1
			) d ON true
			LEFT JOIN daily_nutrient_totals t ON t.nutrient_id = n.id AND t.user_id = $1 AND t.logged_on = $2::date
			WHERE d.amount IS NOT NULL
			  AND COALESCE((t.amount / d.amount) * 100, 0) < 80
			ORDER BY COALESCE((t.amount / d.amount) * 100, 0) ASC
			LIMIT 5
		)
		SELECT DISTINCT ON (low.code)
			low.code,
			low.name,
			low.percent,
			f.id,
			f.name
		FROM low
		JOIN food_nutrients fn ON fn.nutrient_id = low.nutrient_id
		JOIN foods f ON f.id = fn.food_id AND f.deleted_at IS NULL
		ORDER BY low.code, fn.amount_per_100g DESC
	`, userID, date)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	recommendations := []Recommendation{}
	for rows.Next() {
		var recommendation Recommendation
		if err := rows.Scan(&recommendation.Code, &recommendation.Name, &recommendation.Percent, &recommendation.FoodID, &recommendation.FoodName); err != nil {
			return nil, err
		}
		recommendation.Message = "You are below target for " + recommendation.Name + ". Try adding " + recommendation.FoodName + "."
		recommendations = append(recommendations, recommendation)
	}
	return recommendations, rows.Err()
}
