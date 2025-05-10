CREATE TABLE entitlements (
  id               BIGSERIAL  PRIMARY KEY,
  user_id          UUID       NOT NULL,
  course_id        INTEGER    NOT NULL,
  order_id         UUID       NOT NULL,
  entitled_at      TIMESTAMP  NOT NULL DEFAULT now(),
  CONSTRAINT uq_user_course   UNIQUE(user_id, course_id),
);
CREATE INDEX idx_ent_user   ON entitlements(user_id);
CREATE INDEX idx_ent_course ON entitlements(course_id);