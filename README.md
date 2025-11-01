# TicketBoard Backend

Backend REST API service for the TicketBoard application, built with Node.js and Express.

## 📚 Related Documentation

- **Main Project:** [../README.md](../README.md) - Complete project overview and deployment
- **Architecture:** [../ARCHITECTURE.md](../ARCHITECTURE.md) - System architecture and design
- **Frontend Service:** [../ticketboard-frontend/README.md](../ticketboard-frontend/README.md) - React frontend application
- **GitHub Actions Setup:** [../GITHUB_ACTIONS_SETUP.md](../GITHUB_ACTIONS_SETUP.md) - CI/CD configuration

## 🎯 Overview

The TicketBoard Backend is a lightweight REST API that provides ticket management functionality. It serves as the data layer for the TicketBoard application, handling all ticket CRUD operations.

### Key Features

- ✅ RESTful API endpoints
- ✅ In-memory ticket storage
- ✅ Health check endpoint for Kubernetes probes
- ✅ CORS-ready for frontend integration
- ✅ Express.js middleware support
- ✅ Dockerized for containerized deployment

## 🛠️ Tech Stack

- **Runtime:** Node.js 20 (Debian Bullseye Slim)
- **Framework:** Express.js 4.21.1
- **Middleware:** body-parser 1.20.3
- **Container:** Docker (multi-stage build)

## 📋 Prerequisites

- Node.js 18+ (for local development)
- npm (comes with Node.js)
- Docker (optional, for containerization)

## 🚀 Quick Start

### Local Development

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Start the server:**
   ```bash
   npm start
   ```

3. **Server runs on:**
   ```
   http://localhost:3000
   ```

4. **Test the API:**
   ```bash
   # Health check
   curl http://localhost:3000/healthz
   
   # Get all tickets
   curl http://localhost:3000/tickets
   
   # Create a ticket
   curl -X POST http://localhost:3000/tickets \
     -H "Content-Type: application/json" \
     -d '{"title":"Test ticket"}'
   ```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3000` | Server port number |

Example:
```bash
PORT=8080 npm start
```

## 🔌 API Endpoints

### Health Check

```http
GET /healthz
```

**Response:** `200 OK`
```
ok
```

Used by Kubernetes readiness and liveness probes.

---

### Get All Tickets

```http
GET /tickets
```

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "title": "Test ticket",
    "status": "open"
  }
]
```

---

### Create Ticket

```http
POST /tickets
```

**Request Body:**
```json
{
  "title": "New ticket title"
}
```

**Response:** `201 Created`
```json
{
  "id": 2,
  "title": "New ticket title",
  "status": "open"
}
```

**Notes:**
- `title` is optional (defaults to "Untitled")
- `id` is auto-generated
- `status` defaults to "open"

## 🐳 Docker

### Build Image

```bash
docker build -t ticketboard-backend:latest .
```

### Run Container

```bash
# Default port
docker run -p 3000:3000 ticketboard-backend:latest

# Custom port
docker run -p 8080:8080 -e PORT=8080 ticketboard-backend:latest
```

### Docker Image Details

**Base Image:** `node:20-bullseye-slim`

**Multi-stage build:**
- Stage 1: Install production dependencies
- Security updates applied during build
- CA certificates included
- Minimal attack surface

**Size:** ~200MB (optimized)

## ☸️ Kubernetes Deployment

### Deploy to Cluster

```bash
# From ticketboard-backend directory
cd k8s

# Create namespace (if not exists)
kubectl apply -f namespace.yaml

# Deploy backend
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
```

### Kubernetes Resources

**Deployment:**
- Replicas: 2 (High Availability)
- Resource requests: 100m CPU, 128Mi Memory
- Resource limits: 500m CPU, 256Mi Memory
- Readiness probe: `/healthz` (5s initial, 5s period)
- Liveness probe: `/healthz` (10s initial, 10s period)

**Service:**
- Type: LoadBalancer
- Port: 3000
- Target Port: 3000
- Internal DNS: `ticketboard-backend.ticketboard.svc.cluster.local`

### Verify Deployment

```bash
# Check pods
kubectl get pods -n ticketboard -l app=ticketboard-backend

# Check service
kubectl get svc -n ticketboard ticketboard-backend

# View logs
kubectl logs -n ticketboard -l app=ticketboard-backend --tail=50

# Port forward for local testing
kubectl port-forward -n ticketboard svc/ticketboard-backend 3000:3000
```

## 🔄 Integration with Frontend

The backend is designed to work seamlessly with the [TicketBoard Frontend](../ticketboard-frontend/README.md).

### Frontend Configuration

The frontend connects to the backend using the `REACT_APP_API_URL` environment variable:

**Local Development:**
```bash
# Frontend connects to local backend
REACT_APP_API_URL=http://localhost:3000
```

**Kubernetes:**
```bash
# Frontend connects via internal service DNS
REACT_APP_API_URL=http://ticketboard-backend.ticketboard.svc.cluster.local:3000
```

### CORS Configuration

If you need to enable CORS for different origins, modify `index.js`:

```javascript
const cors = require('cors');

app.use(cors({
  origin: ['http://localhost:3000', 'https://yourdomain.com']
}));
```

## 🧪 Testing

### Run Tests

```bash
npm test
```

**Note:** Tests are not yet implemented. Current command is a placeholder.

### Manual Testing

```bash
# Start server
npm start

# In another terminal
# Test health endpoint
curl http://localhost:3000/healthz

# Test GET tickets
curl http://localhost:3000/tickets

# Test POST ticket
curl -X POST http://localhost:3000/tickets \
  -H "Content-Type: application/json" \
  -d '{"title":"My new ticket"}'
```

## 📁 Project Structure

```
ticketboard-backend/
├── README.md              # This file
├── Dockerfile             # Container image definition
├── package.json           # Dependencies and scripts
├── package-lock.json      # Locked dependency versions
├── index.js               # Main application entry point
└── k8s/                   # Kubernetes manifests
    ├── namespace.yaml     # Namespace definition
    ├── backend-deployment.yaml  # Deployment configuration
    └── backend-service.yaml     # Service configuration
```

## 🔧 Development

### Adding New Endpoints

Edit `index.js` to add new routes:

```javascript
// Example: Update ticket status
app.patch('/tickets/:id', (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  
  const ticket = tickets.find(t => t.id === parseInt(id));
  
  if (!ticket) {
    return res.status(404).json({ error: 'Ticket not found' });
  }
  
  ticket.status = status;
  res.json(ticket);
});
```

### Adding Database Persistence

Current implementation uses in-memory storage. To add persistence:

1. **Install database driver:**
   ```bash
   npm install pg  # PostgreSQL
   # or
   npm install mongodb  # MongoDB
   ```

2. **Update `index.js`** to use database instead of `tickets` array

3. **Add database configuration** via environment variables

4. **Update Kubernetes manifests** to include database connection details

## 📦 Container Registry

Images are published to GitHub Container Registry (GHCR):

```bash
# Pull image
docker pull ghcr.io/ghostgto/ticketboard-backend:latest

# Run from registry
docker run -p 3000:3000 ghcr.io/ghostgto/ticketboard-backend:latest
```

### Building and Pushing

```bash
# Build
docker build -t ghcr.io/YOUR_USERNAME/ticketboard-backend:latest .

# Login to GHCR
echo $GHCR_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin

# Push
docker push ghcr.io/YOUR_USERNAME/ticketboard-backend:latest
```

## 🔐 Security Considerations

1. **No Secrets in Code:** Use environment variables for sensitive data
2. **Minimal Base Image:** Uses slim Debian image
3. **Security Updates:** Applied during Docker build
4. **Health Checks:** Kubernetes probes detect unhealthy containers
5. **Resource Limits:** Prevents resource exhaustion

### Recommended Enhancements

- [ ] Add authentication/authorization
- [ ] Implement rate limiting
- [ ] Add request validation
- [ ] Use helmet.js for security headers
- [ ] Implement structured logging
- [ ] Add database encryption at rest

## 📊 Monitoring

### Health Check

The `/healthz` endpoint returns `200 OK` when the server is running:

```bash
curl -i http://localhost:3000/healthz
```

### Kubernetes Probes

**Readiness Probe:**
- Checks if pod is ready to receive traffic
- Initial delay: 5 seconds
- Period: 5 seconds

**Liveness Probe:**
- Checks if pod is still running
- Initial delay: 10 seconds
- Period: 10 seconds

### Logs

```bash
# Local development
# Logs output to stdout

# Kubernetes
kubectl logs -n ticketboard -l app=ticketboard-backend -f
```

## 🐛 Troubleshooting

### Port Already in Use

```bash
# Find process using port 3000
lsof -i :3000

# Kill the process
kill -9 <PID>

# Or use a different port
PORT=3001 npm start
```

### Module Not Found

```bash
# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

### Docker Build Fails

```bash
# Clear Docker cache
docker builder prune -a

# Rebuild without cache
docker build --no-cache -t ticketboard-backend:latest .
```

### Kubernetes Pod Not Starting

```bash
# Check pod status
kubectl describe pod -n ticketboard <pod-name>

# Check logs
kubectl logs -n ticketboard <pod-name>

# Common issues:
# - Image pull errors (check GHCR access)
# - Resource limits too low
# - Health check failing
```

## 🤝 Contributing

See the [main project README](../README.md) for contribution guidelines.

## 📝 License

MIT - See [main project README](../README.md) for details.

## 👤 Author

Gustavo Tejeda

## 🔗 Links

- **Main Project:** [TicketBoard](../README.md)
- **Frontend:** [ticketboard-frontend](../ticketboard-frontend/README.md)
- **Docker Hub:** [ghcr.io/ghostgto/ticketboard-backend](https://ghcr.io/ghostgto/ticketboard-backend)
- **Issues:** Report bugs and request features in the main repository

---

**Part of the TicketBoard Project** | [View Full Documentation](../README.md)
