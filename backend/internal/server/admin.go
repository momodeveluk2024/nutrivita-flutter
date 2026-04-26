package server

import (
	"errors"
	"net/http"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/momodeveluk2024/nutrivita-flutter/backend/internal/auth"
	"github.com/momodeveluk2024/nutrivita-flutter/backend/internal/db"
	"github.com/momodeveluk2024/nutrivita-flutter/backend/internal/httpx"
)

type adminLoginRequest struct {
	Email    string `json:"email" validate:"required,email,max=320"`
	Password string `json:"password" validate:"required,min=1,max=128"`
}

type updateAdminNutrientDRIRequest struct {
	Amount float64 `json:"amount" validate:"required,gt=0,lte=100000"`
}

type updateAdminFoodRequest struct {
	Name         *string                 `json:"name" validate:"omitempty,min=1,max=180"`
	Brand        *string                 `json:"brand" validate:"omitempty,max=120"`
	Category     *string                 `json:"category" validate:"omitempty,min=1,max=80"`
	ServingSizeG *float64                `json:"servingSizeG" validate:"omitempty,gt=0,lte=10000"`
	Nutrients    []db.CreateFoodNutrient `json:"nutrients" validate:"omitempty,max=64,dive"`
}

func (a *App) handleAdminLogin(w http.ResponseWriter, r *http.Request) {
	var request adminLoginRequest
	if !a.readAndValidate(w, r, &request) {
		return
	}

	email := strings.ToLower(strings.TrimSpace(request.Email))
	if retryAt, locked := a.lockouts.isLocked(email, a.now()); locked {
		httpx.WriteError(w, http.StatusTooManyRequests, "account temporarily locked until "+retryAt.Format(http.TimeFormat))
		return
	}

	user, err := a.store.GetUserByEmail(r.Context(), email)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			a.lockouts.recordFailure(email, a.now())
			httpx.WriteError(w, http.StatusUnauthorized, "invalid email or password")
			return
		}
		a.logger.Error("load admin user", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not login")
		return
	}
	if user.Role != "admin" {
		httpx.WriteError(w, http.StatusForbidden, "admin access required")
		return
	}

	ok, err := auth.VerifyPassword(request.Password, user.PasswordHash)
	if err != nil || !ok {
		a.lockouts.recordFailure(email, a.now())
		httpx.WriteError(w, http.StatusUnauthorized, "invalid email or password")
		return
	}
	a.lockouts.clear(email)

	response, err := a.issueAuthResponse(r, user.ID, http.StatusOK)
	if err != nil {
		a.logger.Error("issue admin tokens", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not create session")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, response)
}

func (a *App) requireAdmin(next http.Handler) http.Handler {
	return a.requireAuth(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		claims := authFromContext(r.Context())
		if claims == nil {
			httpx.WriteError(w, http.StatusUnauthorized, "unauthorized")
			return
		}
		user, err := a.store.GetUserByID(r.Context(), claims.UserID)
		if err != nil {
			httpx.WriteError(w, http.StatusUnauthorized, "unauthorized")
			return
		}
		if user.Role != "admin" {
			httpx.WriteError(w, http.StatusForbidden, "admin access required")
			return
		}
		next.ServeHTTP(w, r)
	}))
}

func (a *App) handleAdminMe(w http.ResponseWriter, r *http.Request) {
	claims := authFromContext(r.Context())
	me, err := a.store.GetMe(r.Context(), claims.UserID)
	if err != nil {
		httpx.WriteError(w, http.StatusUnauthorized, "unauthorized")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, me)
}

func (a *App) handleAdminOverview(w http.ResponseWriter, r *http.Request) {
	overview, err := a.store.GetAdminOverview(r.Context(), a.now())
	if err != nil {
		a.logger.Error("admin overview", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not load overview")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, overview)
}

func (a *App) handleAdminUsers(w http.ResponseWriter, r *http.Request) {
	users, err := a.store.ListAdminUsers(r.Context(), r.URL.Query().Get("status"), parseLimit(r, 50))
	if err != nil {
		a.logger.Error("admin users", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not list users")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{"users": users})
}

func (a *App) handleAdminUser(w http.ResponseWriter, r *http.Request) {
	userID, ok := parseUUIDURLParam(w, r, "userID")
	if !ok {
		return
	}
	user, err := a.store.GetAdminUser(r.Context(), userID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, http.StatusNotFound, "user not found")
			return
		}
		a.logger.Error("admin user", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not load user")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, user)
}

func (a *App) handleAdminLogs(w http.ResponseWriter, r *http.Request) {
	var userID uuid.UUID
	if raw := strings.TrimSpace(r.URL.Query().Get("user_id")); raw != "" {
		parsed, err := uuid.Parse(raw)
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid user_id")
			return
		}
		userID = parsed
	}
	logs, err := a.store.ListAdminMealLogs(r.Context(), userID, r.URL.Query().Get("from"), r.URL.Query().Get("to"), parseLimit(r, 50))
	if err != nil {
		a.logger.Error("admin logs", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not list logs")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{"logs": logs})
}

func (a *App) handleAdminNutrients(w http.ResponseWriter, r *http.Request) {
	nutrients, err := a.store.ListAdminNutrients(r.Context())
	if err != nil {
		a.logger.Error("admin nutrients", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not list nutrients")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{"nutrients": nutrients})
}

func (a *App) handleAdminUpdateNutrientDRI(w http.ResponseWriter, r *http.Request) {
	var request updateAdminNutrientDRIRequest
	if !a.readAndValidate(w, r, &request) {
		return
	}
	nutrient, err := a.store.UpdateAdminNutrientDRI(r.Context(), chi.URLParam(r, "code"), request.Amount)
	if err != nil {
		a.logger.Error("admin update nutrient dri", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not update nutrient")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, nutrient)
}

func (a *App) handleAdminFoods(w http.ResponseWriter, r *http.Request) {
	foods, err := a.store.ListAdminFoods(
		r.Context(),
		r.URL.Query().Get("q"),
		r.URL.Query().Get("category"),
		r.URL.Query().Get("verified"),
		parseLimit(r, 50),
	)
	if err != nil {
		a.logger.Error("admin foods", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not list foods")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{"foods": foods})
}

func (a *App) handleAdminUpdateFood(w http.ResponseWriter, r *http.Request) {
	foodID, ok := parseUUIDURLParam(w, r, "foodID")
	if !ok {
		return
	}
	var request updateAdminFoodRequest
	if !a.readAndValidate(w, r, &request) {
		return
	}
	food, err := a.store.UpdateAdminFood(r.Context(), db.UpdateAdminFoodParams{
		ID:               foodID,
		Name:             request.Name,
		Brand:            request.Brand,
		Category:         request.Category,
		ServingSizeG:     request.ServingSizeG,
		Nutrients:        request.Nutrients,
		ReplaceNutrients: request.Nutrients != nil,
	})
	if err != nil {
		a.logger.Error("admin update food", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not update food")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, food)
}

func (a *App) handleAdminVerifyFood(w http.ResponseWriter, r *http.Request) {
	foodID, ok := parseUUIDURLParam(w, r, "foodID")
	if !ok {
		return
	}
	food, err := a.store.VerifyAdminFood(r.Context(), foodID)
	if err != nil {
		a.logger.Error("admin verify food", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not verify food")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, food)
}

func (a *App) handleAdminDeleteFood(w http.ResponseWriter, r *http.Request) {
	foodID, ok := parseUUIDURLParam(w, r, "foodID")
	if !ok {
		return
	}
	if err := a.store.DeleteAdminFood(r.Context(), foodID); err != nil {
		a.logger.Error("admin delete food", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not delete food")
		return
	}
	httpx.WriteNoContent(w)
}

func (a *App) handleAdminReminders(w http.ResponseWriter, r *http.Request) {
	reminders, err := a.store.ListAdminReminders(r.Context(), parseLimit(r, 50))
	if err != nil {
		a.logger.Error("admin reminders", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not list reminders")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{"reminders": reminders})
}

func (a *App) handleAdminAuditLog(w http.ResponseWriter, r *http.Request) {
	entries, err := a.store.ListAdminAuditEntries(r.Context())
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "could not list audit log")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{"entries": entries})
}
