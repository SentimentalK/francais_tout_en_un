CREATE TABLE orders (
  order_id        UUID              PRIMARY KEY,
  user_id         UUID              NOT NULL,
  course_id       INTEGER           NOT NULL,
  amount          DECIMAL(10,2)     NOT NULL,
  currency        VARCHAR(3)        NOT NULL DEFAULT 'USD',
  status          VARCHAR(20)       NOT NULL,
  payment_gateway VARCHAR(50),
  gateway_txn_id  VARCHAR(100),
  created_at      TIMESTAMP         NOT NULL DEFAULT now(),
  updated_at      TIMESTAMP         NOT NULL DEFAULT now(),
  refunded_at     TIMESTAMP,
  refund_reason   TEXT
);
CREATE INDEX idx_orders_user   ON orders(user_id);
CREATE INDEX idx_orders_course ON orders(course_id);