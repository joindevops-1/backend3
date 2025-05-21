# ---- Stage 1: Build Dependencies ----
FROM node:23 as builder

WORKDIR /opt/backend

COPY package.json ./
COPY *.js ./

RUN npm install


# ---- Stage 2: Runtime ----
FROM node:23

# Create non-root user
RUN addgroup --system expense && adduser --system --ingroup expense expense

# Create working directory and assign permissions
RUN mkdir -p /opt/backend && chown -R expense:expense /opt/backend

ENV DB_HOST="mysql"
WORKDIR /opt/backend
USER expense

# Copy files from builder
COPY --from=builder /opt/backend /opt/backend

CMD ["node", "index.js"]
