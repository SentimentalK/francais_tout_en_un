CREATE TABLE IF NOT EXISTS users (
    id              UUID    PRIMARY KEY         DEFAULT gen_random_uuid(),
    username        TEXT    UNIQUE              NOT NULL,
    email           TEXT    UNIQUE              NOT NULL,
    password_hash   TEXT    NOT NULL,
    created_at      TIMESTAMP WITH TIME ZONE    DEFAULT now()
);
