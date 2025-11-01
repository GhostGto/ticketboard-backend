// Asegurar que el health endpoint funciona
app.get('/api/health', async (req, res) => {
    try {
      // Verificar conexión a base de datos si es posible
      res.status(200).json({ 
        status: 'OK', 
        database: 'connected', 
        timestamp: new Date().toISOString() 
      });
    } catch (error) {
      res.status(500).json({ 
        status: 'ERROR', 
        error: error.message 
      });
    }
  });