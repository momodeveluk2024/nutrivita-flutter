package notifications

import (
	"context"
	"log/slog"

	"github.com/google/uuid"
)

type PushMessage struct {
	UserID uuid.UUID
	Title  string
	Body   string
	Data   map[string]string
}

type PushSender interface {
	Send(ctx context.Context, message PushMessage) error
}

type DevLoggerSender struct {
	logger *slog.Logger
}

func NewDevLoggerSender(logger *slog.Logger) *DevLoggerSender {
	return &DevLoggerSender{logger: logger}
}

func (s *DevLoggerSender) Send(ctx context.Context, message PushMessage) error {
	s.logger.InfoContext(ctx, "dev push notification", "user_id", message.UserID, "title", message.Title, "body", message.Body, "data", message.Data)
	return nil
}
