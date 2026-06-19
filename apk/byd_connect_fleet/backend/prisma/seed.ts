import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Create default plans
  const plans = await Promise.all([
    prisma.plan.upsert({
      where: { id: 'plan-starter' },
      update: {},
      create: {
        id: 'plan-starter',
        name: 'Starter',
        description: 'Perfect for small fleets up to 5 vehicles',
        price: 99.90,
        interval: 'month',
        maxCars: 5,
        features: JSON.stringify(['Real-time tracking', 'Basic alerts', 'Mobile app', 'Email support']),
      },
    }),
    prisma.plan.upsert({
      where: { id: 'plan-professional' },
      update: {},
      create: {
        id: 'plan-professional',
        name: 'Professional',
        description: 'For growing fleets up to 20 vehicles',
        price: 249.90,
        interval: 'month',
        maxCars: 20,
        features: JSON.stringify(['Everything in Starter', 'Advanced analytics', '2FA security', 'Priority support', 'API access']),
      },
    }),
    prisma.plan.upsert({
      where: { id: 'plan-enterprise' },
      update: {},
      create: {
        id: 'plan-enterprise',
        name: 'Enterprise',
        description: 'Unlimited vehicles with full features',
        price: 499.90,
        interval: 'month',
        maxCars: 999,
        features: JSON.stringify(['Everything in Professional', 'Unlimited vehicles', 'Custom integrations', 'Dedicated account manager', 'SLA guarantee']),
      },
    }),
  ]);

  console.log('✅ Plans created:', plans.map(p => p.name).join(', '));

  // Create admin user
  const passwordHash = await bcrypt.hash('admin123', 12);
  const admin = await prisma.user.upsert({
    where: { email: 'admin@bydfleet.com' },
    update: {},
    create: {
      email: 'admin@bydfleet.com',
      passwordHash,
      name: 'Admin User',
      role: 'ADMIN',
    },
  });

  console.log('✅ Admin user created:', admin.email);

  // Create a fleet
  const fleet = await prisma.fleet.upsert({
    where: { id: 'fleet-demo' },
    update: {},
    create: {
      id: 'fleet-demo',
      name: 'Demo Fleet',
    },
  });

  console.log('✅ Fleet created:', fleet.name);

  // Create demo drivers
  const drivers = await Promise.all([
    prisma.driver.upsert({
      where: { email: 'john@driver.com' },
      update: {},
      create: {
        email: 'john@driver.com',
        name: 'John Smith',
        phone: '+55 11 99999-0001',
        cpf: '123.456.789-00',
        licenseNumber: 'AB-1234567',
        fleetId: fleet.id,
      },
    }),
    prisma.driver.upsert({
      where: { email: 'maria@driver.com' },
      update: {},
      create: {
        email: 'maria@driver.com',
        name: 'Maria Santos',
        phone: '+55 11 99999-0002',
        cpf: '987.654.321-00',
        licenseNumber: 'CD-7654321',
        fleetId: fleet.id,
      },
    }),
  ]);

  console.log('✅ Drivers created:', drivers.map(d => d.name).join(', '));

  // Create demo cars
  const cars = await Promise.all([
    prisma.car.upsert({
      where: { plate: 'ABC-1234' },
      update: {},
      create: {
        plate: 'ABC-1234',
        model: 'BYD Seal',
        vin: 'VIN1234567890ABCD',
        imageUrl: 'https://example.com/byd-seal.jpg',
        batteryLevel: 87,
        isOnline: true,
        isLocked: true,
        gear: 'P',
        speed: 0,
        range: 420,
        temperature: 24,
        latitude: -23.5505,
        longitude: -46.6333,
        lastSeen: new Date(),
        climateTemp: 22,
        fleetId: fleet.id,
        driverId: drivers[0].id,
      },
    }),
    prisma.car.upsert({
      where: { plate: 'DEF-5678' },
      update: {},
      create: {
        plate: 'DEF-5678',
        model: 'BYD Dolphin',
        vin: 'VIN0987654321WXYZ',
        imageUrl: 'https://example.com/byd-dolphin.jpg',
        batteryLevel: 65,
        isOnline: true,
        isLocked: false,
        gear: 'D',
        speed: 45,
        range: 280,
        temperature: 26,
        latitude: -23.5615,
        longitude: -46.6550,
        lastSeen: new Date(),
        climateTemp: 24,
        fleetId: fleet.id,
        driverId: drivers[1].id,
      },
    }),
    prisma.car.upsert({
      where: { plate: 'GHI-9012' },
      update: {},
      create: {
        plate: 'GHI-9012',
        model: 'BYD Yuan Plus',
        vin: 'VIN5555666677778888',
        batteryLevel: 23,
        isOnline: false,
        isLocked: true,
        gear: 'P',
        speed: 0,
        range: 95,
        temperature: 18,
        latitude: -23.5100,
        longitude: -46.6200,
        lastSeen: new Date(Date.now() - 3600000),
        climateTemp: 20,
        fleetId: fleet.id,
      },
    }),
  ]);

  console.log('✅ Cars created:', cars.map(c => c.plate).join(', '));

  // Create demo alerts
  const alerts = await Promise.all([
    prisma.alert.create({
      data: {
        fleetId: fleet.id,
        carId: cars[2].id,
        type: 'BATTERY',
        title: 'Low Battery Warning',
        description: 'Car GHI-9012 battery level below 25%',
        severity: 'WARNING',
      },
    }),
    prisma.alert.create({
      data: {
        fleetId: fleet.id,
        carId: cars[0].id,
        type: 'MOTION',
        title: 'Movement Detected',
        description: 'Motion sensor triggered while armed',
        severity: 'INFO',
      },
    }),
    prisma.alert.create({
      data: {
        fleetId: fleet.id,
        carId: cars[1].id,
        type: 'SPEED',
        title: 'Speed Alert',
        description: 'Vehicle exceeded 50 km/h',
        severity: 'WARNING',
      },
    }),
  ]);

  console.log('✅ Alerts created:', alerts.length);

  console.log('\n🎉 Seed completed!');
  console.log('\n📧 Login credentials:');
  console.log('   Email: admin@bydfleet.com');
  console.log('   Password: admin123');
  console.log('\n🚀 Start the backend with: cd backend && npm run dev');
}

main()
  .catch((e) => {
    console.error('Seed error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
