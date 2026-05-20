#!/bin/bash
export DB_HOST=localhost
export DB_PORT=5433
export DB_USERNAME=postgres
export DB_PASSWORD=TakaoPass2024
export DB_NAME=taskdb
export NODE_ENV=production
npm run migration:run
