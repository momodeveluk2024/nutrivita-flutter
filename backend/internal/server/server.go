package server

import (
	"context"
	"errors"
	"log/slog"
	"net"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/momodeveluk2024/nutrivita-flutter/backend/internal/auth"
	"github.com/momodeveluk2024/nutrivita-flutter/backend/internal/config"
	"github.com/momodeveluk2024/nutrivita-flutter/backend/internal/db"
	"github.com/momodeveluk2024/nutrivita-flutter/backend/internal/filestore"
	"github.com/momodeveluk2024/nutrivita-flutter/backend/internal/httpx"
	"github.com/momodeveluk2024/nutrivita-flutter/backend/internal/jobs"
	"github.com/momodeveluk2024/nutrivita-flutter/backend/internal/notifications"
)

type App struct {
	cfg       config.Config
	store     *db.Store
	logger    *slog.Logger
	validate  *validator.Validate
	tokenizer auth.TokenManager
	authLimit *rateLimiter
	lockouts  *loginLockouts
	scheduler jobs.ReminderScheduler
	push      notifications.PushSender
	storage   filestore.ObjectStore
	metrics   *metrics
	now       func() time.Time
}

func New(cfg config.Config, store *db.Store, logger *slog.Logger) *App {
	return &App{
		cfg:       cfg,
		store:     store,
		logger:    logger,
		validate:  validator.New(validator.WithRequiredStructEnabled()),
		tokenizer: auth.NewTokenManager(cfg.JWTSecret, cfg.AccessTokenTTL),
		authLimit: newRateLimiter(10, time.Minute),
		lockouts:  newLoginLockouts(5, 15*time.Minute),
		scheduler: jobs.NewNoopReminderScheduler(logger),
		push:      notifications.NewDevLoggerSender(logger),
		storage:   filestore.NewLocalStore("data/uploads", "/uploads"),
		metrics:   newMetrics(),
		now:       time.Now,
	}
}

func (a *App) Routes() http.Handler {
	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Recoverer)
	r.Use(a.observeRequests)
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   a.cfg.AllowedOrigins,
		AllowedMethods:   []string{"GET", "POST", "PATCH", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type"},
		AllowCredentials: false,
		MaxAge:           300,
	}))

	r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
		httpx.WriteJSON(w, http.StatusOK, map[string]string{"status": "ok"})
	})
	r.Get("/ready", func(w http.ResponseWriter, r *http.Request) {
		if err := a.store.Ping(r.Context()); err != nil {
			httpx.WriteError(w, http.StatusServiceUnavailable, "database unavailable")
			return
		}
		httpx.WriteJSON(w, http.StatusOK, map[string]string{"status": "ready"})
	})
	r.Get("/metrics", func(w http.ResponseWriter, r *http.Request) {
		a.metrics.writePrometheus(w)
	})
	r.Handle("/uploads/*", http.StripPrefix("/uploads/", http.FileServer(http.Dir("data/uploads"))))

	r.Route("/v1", func(r chi.Router) {
		r.Group(func(r chi.Router) {
			r.Use(a.authLimit.middleware)
			r.Post("/auth/signup", a.handleSignup)
			r.Post("/auth/login", a.handleLogin)
			r.Post("/auth/refresh", a.handleRefresh)
			r.Post("/auth/verify-email", a.handleVerifyEmail)
			r.Post("/auth/forgot-password", a.handleForgotPassword)
			r.Post("/auth/reset-password", a.handleResetPassword)
			r.Post("/admin/auth/login", a.handleAdminLogin)
		})
		r.Get("/foods", a.handleListFoods)
		r.Get("/foods/barcode/{barcode}", a.handleGetFoodByBarcode)
		r.Get("/foods/{foodID}", a.handleGetFood)
		r.Group(func(r chi.Router) {
			r.Use(a.requireAdmin)
			r.Get("/admin/me", a.handleAdminMe)
			r.Get("/admin/overview", a.handleAdminOverview)
			r.Get("/admin/users", a.handleAdminUsers)
			r.Get("/admin/users/{userID}", a.handleAdminUser)
			r.Patch("/admin/users/{userID}", a.handleAdminUpdateUserProfile)
			r.Post("/admin/users/{userID}/verify", a.handleAdminVerifyUser)
			r.Post("/admin/users/{userID}/suspend", a.handleAdminSuspendUser)
			r.Post("/admin/users/{userID}/unsuspend", a.handleAdminUnsuspendUser)
			r.Delete("/admin/users/{userID}", a.handleAdminDeleteUser)
			r.Delete("/admin/users/{userID}/sessions/{sessionID}", a.handleAdminRevokeUserSession)
			r.Get("/admin/logs", a.handleAdminLogs)
			r.Get("/admin/nutrients", a.handleAdminNutrients)
			r.Post("/admin/nutrients", a.handleAdminCreateNutrient)
			r.Patch("/admin/nutrients/{code}", a.handleAdminUpdateNutrient)
			r.Patch("/admin/nutrients/{code}/dri", a.handleAdminUpdateNutrientDRI)
			r.Get("/admin/foods", a.handleAdminFoods)
			r.Post("/admin/foods", a.handleAdminCreateFood)
			r.Patch("/admin/foods/{foodID}", a.handleAdminUpdateFood)
			r.Post("/admin/foods/{foodID}/image", a.handleAdminUploadFoodImage)
			r.Post("/admin/foods/{foodID}/verify", a.handleAdminVerifyFood)
			r.Delete("/admin/foods/{foodID}", a.handleAdminDeleteFood)
			r.Get("/admin/reminders", a.handleAdminReminders)
			r.Get("/admin/reminder-templates", a.handleAdminReminderTemplates)
			r.Post("/admin/reminder-templates", a.handleAdminCreateReminderTemplate)
			r.Patch("/admin/reminder-templates/{templateID}", a.handleAdminUpdateReminderTemplate)
			r.Get("/admin/audit-log", a.handleAdminAuditLog)
		})
		r.Group(func(r chi.Router) {
			r.Use(a.requireAuth)
			r.Post("/auth/logout", a.handleLogout)
			r.Get("/me", a.handleMe)
			r.Patch("/me/profile", a.handleUpdateProfile)
			r.Post("/me/avatar", a.handleUpdateAvatar)
			r.Patch("/me/preferences", a.handleUpdatePreferences)
			r.Get("/me/streak", a.handleStreak)
			r.Post("/foods", a.handleCreateFood)
			r.Get("/logs", a.handleListLogs)
			r.Post("/logs", a.handleCreateLog)
			r.Delete("/logs/{logID}", a.handleDeleteLog)
			r.Get("/logs/today/intake", a.handleTodayIntake)
			r.Get("/logs/week", a.handleWeekIntake)
			r.Get("/favorites", a.handleListFavorites)
			r.Put("/favorites/{foodID}", a.handleAddFavorite)
			r.Delete("/favorites/{foodID}", a.handleRemoveFavorite)
			r.Get("/reminders", a.handleListReminders)
			r.Post("/reminders", a.handleCreateReminder)
			r.Delete("/reminders/{reminderID}", a.handleDeleteReminder)
			r.Get("/recommendations", a.handleRecommendations)
		})
	})

	return r
}

type signupRequest struct {
	Email       string `json:"email" validate:"required,email,max=320"`
	Password    string `json:"password" validate:"required,min=8,max=128"`
	DisplayName string `json:"display_name" validate:"required,min=1,max=120"`
}

type loginRequest struct {
	Email    string `json:"email" validate:"required,email,max=320"`
	Password string `json:"password" validate:"required,min=1,max=128"`
}

type refreshRequest struct {
	Refresh string `json:"refresh" validate:"required"`
}

type verifyEmailRequest struct {
	Token string `json:"token" validate:"required"`
}

type forgotPasswordRequest struct {
	Email string `json:"email" validate:"required,email,max=320"`
}

type resetPasswordRequest struct {
	Token       string `json:"token" validate:"required"`
	NewPassword string `json:"new_password" validate:"required,min=8,max=128"`
}

type authResponse struct {
	Access  string `json:"access"`
	Refresh string `json:"refresh"`
	User    db.Me  `json:"user"`
}

type refreshResponse struct {
	Access  string `json:"access"`
	Refresh string `json:"refresh"`
}

func (a *App) handleSignup(w http.ResponseWriter, r *http.Request) {
	var request signupRequest
	if !a.readAndValidate(w, r, &request) {
		return
	}

	passwordHash, err := auth.HashPassword(request.Password)
	if err != nil {
		a.logger.Error("hash password", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not create account")
		return
	}

	userID, err := uuid.NewV7()
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "could not create account")
		return
	}

	user, _, err := a.store.CreateUserWithProfile(r.Context(), db.CreateUserParams{
		ID:           userID,
		Email:        strings.ToLower(strings.TrimSpace(request.Email)),
		PasswordHash: passwordHash,
		DisplayName:  strings.TrimSpace(request.DisplayName),
	})
	if err != nil {
		if isUniqueViolation(err) {
			httpx.WriteError(w, http.StatusConflict, "email already exists")
			return
		}
		a.logger.Error("create user", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not create account")
		return
	}

	if token, tokenHash, err := auth.NewRefreshToken(); err == nil {
		if err := a.store.CreateEmailVerification(r.Context(), user.ID, tokenHash, a.now().Add(24*time.Hour)); err == nil {
			a.logger.Info("dev email verification token", "email", user.Email, "token", token)
		}
	}

	response, err := a.issueAuthResponse(r, user.ID, http.StatusCreated)
	if err != nil {
		a.logger.Error("issue tokens", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not create session")
		return
	}
	httpx.WriteJSON(w, http.StatusCreated, response)
}

func (a *App) handleLogin(w http.ResponseWriter, r *http.Request) {
	var request loginRequest
	if !a.readAndValidate(w, r, &request) {
		return
	}
	email := strings.ToLower(strings.TrimSpace(request.Email))
	if retryAt, locked := a.lockouts.isLocked(email, a.now()); locked {
		httpx.WriteError(w, http.StatusTooManyRequests, "account temporarily locked until "+retryAt.Format(time.RFC3339))
		return
	}

	user, err := a.store.GetUserByEmail(r.Context(), email)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			a.lockouts.recordFailure(email, a.now())
			httpx.WriteError(w, http.StatusUnauthorized, "invalid email or password")
			return
		}
		a.logger.Error("load user", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not login")
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
		a.logger.Error("issue tokens", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not create session")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, response)
}

func (a *App) handleRefresh(w http.ResponseWriter, r *http.Request) {
	var request refreshRequest
	if !a.readAndValidate(w, r, &request) {
		return
	}

	session, err := a.store.GetActiveSessionByRefreshHash(r.Context(), auth.HashRefreshToken(request.Refresh))
	if err != nil {
		httpx.WriteError(w, http.StatusUnauthorized, "invalid refresh token")
		return
	}

	refresh, refreshHash, err := auth.NewRefreshToken()
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "could not refresh session")
		return
	}

	session, err = a.store.RotateSession(r.Context(), session.ID, refreshHash, a.now().Add(a.cfg.RefreshTokenTTL))
	if err != nil {
		httpx.WriteError(w, http.StatusUnauthorized, "invalid refresh token")
		return
	}

	access, err := a.tokenizer.IssueAccessToken(session.UserID, session.ID, a.now())
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "could not issue token")
		return
	}

	httpx.WriteJSON(w, http.StatusOK, refreshResponse{Access: access, Refresh: refresh})
}

func (a *App) handleVerifyEmail(w http.ResponseWriter, r *http.Request) {
	var request verifyEmailRequest
	if !a.readAndValidate(w, r, &request) {
		return
	}
	if _, err := a.store.VerifyEmailToken(r.Context(), auth.HashRefreshToken(request.Token)); err != nil {
		httpx.WriteError(w, http.StatusUnauthorized, "invalid verification token")
		return
	}
	httpx.WriteNoContent(w)
}

func (a *App) handleForgotPassword(w http.ResponseWriter, r *http.Request) {
	var request forgotPasswordRequest
	if !a.readAndValidate(w, r, &request) {
		return
	}
	user, err := a.store.GetUserByEmail(r.Context(), strings.ToLower(strings.TrimSpace(request.Email)))
	if err == nil {
		if token, tokenHash, err := auth.NewRefreshToken(); err == nil {
			if err := a.store.CreatePasswordReset(r.Context(), user.ID, tokenHash, a.now().Add(time.Hour)); err == nil {
				a.logger.Info("dev password reset token", "email", user.Email, "token", token)
			}
		}
	}
	httpx.WriteNoContent(w)
}

func (a *App) handleResetPassword(w http.ResponseWriter, r *http.Request) {
	var request resetPasswordRequest
	if !a.readAndValidate(w, r, &request) {
		return
	}
	passwordHash, err := auth.HashPassword(request.NewPassword)
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "could not reset password")
		return
	}
	if _, err := a.store.ResetPassword(r.Context(), auth.HashRefreshToken(request.Token), passwordHash); err != nil {
		httpx.WriteError(w, http.StatusUnauthorized, "invalid reset token")
		return
	}
	httpx.WriteNoContent(w)
}

func (a *App) handleLogout(w http.ResponseWriter, r *http.Request) {
	claims := authFromContext(r.Context())
	if claims == nil {
		httpx.WriteError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	if err := a.store.RevokeSession(r.Context(), claims.SessionID); err != nil {
		a.logger.Error("revoke session", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not logout")
		return
	}

	httpx.WriteNoContent(w)
}

func (a *App) handleMe(w http.ResponseWriter, r *http.Request) {
	claims := authFromContext(r.Context())
	if claims == nil {
		httpx.WriteError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	me, err := a.store.GetMe(r.Context(), claims.UserID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, http.StatusNotFound, "user not found")
			return
		}
		a.logger.Error("get me", "error", err)
		httpx.WriteError(w, http.StatusInternalServerError, "could not load profile")
		return
	}

	httpx.WriteJSON(w, http.StatusOK, me)
}

func (a *App) issueAuthResponse(r *http.Request, userID uuid.UUID, _ int) (authResponse, error) {
	sessionID, err := uuid.NewV7()
	if err != nil {
		return authResponse{}, err
	}
	refresh, refreshHash, err := auth.NewRefreshToken()
	if err != nil {
		return authResponse{}, err
	}

	session, err := a.store.CreateSession(
		r.Context(),
		sessionID,
		userID,
		refreshHash,
		r.UserAgent(),
		clientIP(r),
		a.now().Add(a.cfg.RefreshTokenTTL),
	)
	if err != nil {
		return authResponse{}, err
	}

	access, err := a.tokenizer.IssueAccessToken(userID, session.ID, a.now())
	if err != nil {
		return authResponse{}, err
	}

	me, err := a.store.GetMe(r.Context(), userID)
	if err != nil {
		return authResponse{}, err
	}

	return authResponse{Access: access, Refresh: refresh, User: me}, nil
}

func (a *App) readAndValidate(w http.ResponseWriter, r *http.Request, target any) bool {
	if err := httpx.ReadJSON(r, target); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "invalid json")
		return false
	}
	if err := a.validate.Struct(target); err != nil {
		httpx.WriteError(w, http.StatusUnprocessableEntity, "invalid request")
		return false
	}
	return true
}

type authContextKey struct{}

type authContext struct {
	UserID    uuid.UUID
	SessionID uuid.UUID
}

func (a *App) requireAuth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		header := r.Header.Get("Authorization")
		if !strings.HasPrefix(header, "Bearer ") {
			httpx.WriteError(w, http.StatusUnauthorized, "unauthorized")
			return
		}

		userID, sessionID, err := a.tokenizer.ParseAccessToken(strings.TrimPrefix(header, "Bearer "))
		if err != nil {
			httpx.WriteError(w, http.StatusUnauthorized, "unauthorized")
			return
		}

		session, err := a.store.GetActiveSessionByID(r.Context(), sessionID)
		if err != nil || session.UserID != userID {
			httpx.WriteError(w, http.StatusUnauthorized, "unauthorized")
			return
		}

		ctx := context.WithValue(r.Context(), authContextKey{}, &authContext{
			UserID:    userID,
			SessionID: sessionID,
		})
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

func authFromContext(ctx context.Context) *authContext {
	claims, _ := ctx.Value(authContextKey{}).(*authContext)
	return claims
}

func clientIP(r *http.Request) string {
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err == nil {
		return host
	}
	return r.RemoteAddr
}

func isUniqueViolation(err error) bool {
	return strings.Contains(err.Error(), "SQLSTATE 23505")
}

type loginLockouts struct {
	mu       sync.Mutex
	limit    int
	duration time.Duration
	attempts map[string]loginAttempt
}

type loginAttempt struct {
	count    int
	lockedAt time.Time
}

func newLoginLockouts(limit int, duration time.Duration) *loginLockouts {
	return &loginLockouts{limit: limit, duration: duration, attempts: map[string]loginAttempt{}}
}

func (l *loginLockouts) recordFailure(email string, now time.Time) {
	l.mu.Lock()
	defer l.mu.Unlock()
	attempt := l.attempts[email]
	attempt.count++
	if attempt.count >= l.limit && attempt.lockedAt.IsZero() {
		attempt.lockedAt = now
	}
	l.attempts[email] = attempt
}

func (l *loginLockouts) isLocked(email string, now time.Time) (time.Time, bool) {
	l.mu.Lock()
	defer l.mu.Unlock()
	attempt := l.attempts[email]
	if attempt.lockedAt.IsZero() {
		return time.Time{}, false
	}
	retryAt := attempt.lockedAt.Add(l.duration)
	if now.After(retryAt) {
		delete(l.attempts, email)
		return time.Time{}, false
	}
	return retryAt, true
}

func (l *loginLockouts) clear(email string) {
	l.mu.Lock()
	defer l.mu.Unlock()
	delete(l.attempts, email)
}
