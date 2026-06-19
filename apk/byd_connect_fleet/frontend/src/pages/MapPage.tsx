import { useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import { motion } from 'framer-motion';
import { Car as CarIcon } from 'lucide-react';
import { GlassCard } from '../components/glass/GlassCard';
import { StatusIndicator } from '../components/glass/StatusIndicator';
import { DashboardLayout } from '../components/layout/DashboardLayout';
import { useFleetStore } from '../store/fleetStore';
import { useCars } from '../hooks/useCars';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

// Fix for default marker icons in Leaflet with bundlers
const carIcon = L.icon({
  iconUrl: 'https://cdn-icons-png.flaticon.com/512/741/741407.png',
  iconRetinaUrl: 'https://cdn-icons-png.flaticon.com/512/741/741407.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
  iconSize: [40, 40],
  iconAnchor: [20, 20],
  popupAnchor: [0, -20],
});
L.Marker.prototype.options.icon = carIcon;

const MapUpdater = ({ cars }: { cars: any[] }) => {
  const map = useMap();

  useEffect(() => {
    if (cars.length > 0) {
      const validCoords = cars.filter((c) => c.latitude && c.longitude);
      if (validCoords.length > 0) {
        const bounds = L.latLngBounds(validCoords.map((c) => [c.latitude!, c.longitude!]));
        map.fitBounds(bounds, { padding: [50, 50] });
      }
    }
  }, [cars, map]);

  return null;
};

export const MapPage = () => {
  const { cars } = useCars();
  const { setSelectedCarId } = useFleetStore();

  const carsWithLocation = cars.filter((car) => car.latitude && car.longitude);

  return (
    <DashboardLayout>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        className="space-y-6"
      >
        <div>
          <h1 className="text-3xl font-bold">Mapa ao Vivo</h1>
          <p className="text-gray-500 mt-1">
            {carsWithLocation.length} veículos com localização disponível
          </p>
        </div>

        <GlassCard className="p-0 overflow-hidden">
          <MapContainer
            center={[-23.5505, -46.6333]}
            zoom={12}
            className="h-[calc(100vh-220px)] w-full"
          >
            <TileLayer
              attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            />
            <MapUpdater cars={carsWithLocation} />
            {carsWithLocation.map((car) => (
              <Marker
                key={car.id}
                position={[car.latitude!, car.longitude!]}
              >
                <Popup>
                  <div className="text-center p-2">
                    <p className="font-bold">{car.model}</p>
                    <p className="text-sm text-gray-500">{car.plate}</p>
                    <div className="mt-2">
                      <StatusIndicator status={car.isOnline ? 'online' : 'offline'} />
                    </div>
                    <button
                      onClick={() => setSelectedCarId(car.id)}
                      className="mt-2 px-3 py-1 bg-blue-600 text-white rounded-lg text-sm"
                    >
                      Ver detalhes
                    </button>
                  </div>
                </Popup>
              </Marker>
            ))}
          </MapContainer>
        </GlassCard>

        {/* Car List Below Map */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {carsWithLocation.map((car) => (
            <GlassCard
              key={car.id}
              hover
              onClick={() => setSelectedCarId(car.id)}
              className="p-4 flex items-center gap-4"
            >
              <div
                className={`w-10 h-10 rounded-full flex items-center justify-center ${
                  car.isOnline ? 'bg-green-500/20' : 'bg-gray-500/20'
                }`}
              >
                <CarIcon className={`w-5 h-5 ${car.isOnline ? 'text-green-500' : 'text-gray-500'}`} />
              </div>
              <div className="flex-1">
                <p className="font-medium">{car.model}</p>
                <p className="text-sm text-gray-500">{car.plate}</p>
              </div>
              <StatusIndicator status={car.isOnline ? 'online' : 'offline'} />
            </GlassCard>
          ))}
        </div>
      </motion.div>
    </DashboardLayout>
  );
};
