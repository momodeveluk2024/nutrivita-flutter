package server

import (
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/momodeveluk2024/nutrivita-flutter/backend/internal/config"
)

func TestProfileAvatarRouteRequiresAuthInsteadOf404(t *testing.T) {
	app := New(config.Config{
		AppEnv:          "test",
		JWTSecret:       "this-is-a-test-secret-with-enough-length",
		AccessTokenTTL:  15 * time.Minute,
		RefreshTokenTTL: 30 * 24 * time.Hour,
		AllowedOrigins:  []string{"*"},
	}, nil, slog.New(slog.NewTextHandler(io.Discard, nil)))

	request := httptest.NewRequest(http.MethodPost, "/v1/me/avatar", nil)
	recorder := httptest.NewRecorder()

	app.Routes().ServeHTTP(recorder, request)

	if recorder.Code != http.StatusUnauthorized {
		t.Fatalf("POST /v1/me/avatar status = %d, want %d", recorder.Code, http.StatusUnauthorized)
	}
}
