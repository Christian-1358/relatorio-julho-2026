import { Router } from 'express';
import { carController } from '../controllers/carController.js';
import { authenticateToken } from '../middleware/authMiddleware.js';

const router = Router();

router.use(authenticateToken);

router.get('/', carController.getAllCars);
router.get('/stats', carController.getFleetStats);
router.get('/:id', carController.getCarById);
router.get('/:id/status', carController.getCarStatus);
router.post('/:id/command', carController.sendCommand);
router.post('/', carController.createCar);
router.delete('/:id', carController.deleteCar);
router.put('/:id/driver', carController.assignDriver);

export default router;
