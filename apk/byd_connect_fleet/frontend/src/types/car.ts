export interface Car {
  id: string;
  plate: string;
  model: string;
  vin: string;
  imageUrl?: string;
  batteryLevel: number;
  isOnline: boolean;
  isLocked: boolean;
  gear: string;
  speed: number;
  range: number;
  temperature: number;
  latitude?: number;
  longitude?: number;
  lastSeen?: string;
  tirePressureFL?: number;
  tirePressureFR?: number;
  tirePressureRL?: number;
  tirePressureRR?: number;
  voltage12V?: number;
  odometer?: number;
  acIsOn: boolean;
  trunkIsOpen: boolean;
  lightsAreOn: boolean;
  engineRunning: boolean;
  climateTemp: number;
  driverId?: string;
  fleetId?: string;
  driver?: Driver;
  createdAt: string;
  updatedAt: string;
}

export interface Driver {
  id: string;
  name: string;
  email: string;
  phone?: string;
  cpf: string;
  licenseNumber?: string;
  isActive: boolean;
  fleetId?: string;
  cars?: Car[];
  createdAt: string;
  updatedAt: string;
}

export interface Alert {
  id: string;
  type: AlertType;
  title: string;
  description?: string;
  carId?: string;
  isRead: boolean;
  severity: Severity;
  fleetId?: string;
  car?: Car;
  createdAt: string;
}

export type AlertType = 'MOTION' | 'DOOR' | 'ALARM' | 'BATTERY' | 'TEMPERATURE' | 'SPEED' | 'GEOFENCE' | 'MAINTENANCE';
export type Severity = 'INFO' | 'WARNING' | 'ERROR' | 'CRITICAL';

export interface FleetStats {
  totalCars: number;
  onlineCars: number;
  alertsCount: number;
  driversCount: number;
}

export interface Plan {
  id: string;
  name: string;
  description?: string;
  price: number;
  interval: string;
  maxCars: number;
  features: string[];
  isActive: boolean;
}

export interface Subscription {
  id: string;
  userId: string;
  planId: string;
  status: 'ACTIVE' | 'PAUSED' | 'CANCELLED' | 'EXPIRED';
  startedAt: string;
  expiresAt?: string;
  plan?: Plan;
}

export interface CarCommand {
  command: 'lock' | 'unlock' | 'climate' | 'engine' | 'lights' | 'trunk' | 'horn';
  params?: Record<string, unknown>;
}

export interface Location {
  lat: number;
  lng: number;
  timestamp?: number;
}
