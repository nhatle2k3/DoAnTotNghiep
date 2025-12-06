import React, { useEffect, useState } from 'react';
import { api } from '../api';
import TableGrid from '../components/TableGrid';

export default function Tables({ token }) {
  const [locations, setLocations] = useState([]);
  const [floors, setFloors] = useState([]);
  const [tables, setTables] = useState([]);
  const [locationId, setLocationId] = useState(null);
  const [floorId, setFloorId] = useState(null);

  const loadLocations = async ()=>{
    const data = await api('/tables/locations');
    setLocations(data);
    if (data.length) setLocationId(data[0].id);
  };
  const loadFloors = async (loc)=>{
    const data = await api(`/tables/floors?location_id=${loc}`);
    setFloors(data);
    if (data.length) setFloorId(data[0].id);
  };
  const loadTables = async (loc, floor)=>{
    const data = await api(`/tables?location_id=${loc}&floor_id=${floor}`);
    setTables(data);
  };

  const handleTableUpdate = () => {
    // Reload tables when status is updated
    if (locationId && floorId) {
      loadTables(locationId, floorId);
    }
  };

  useEffect(()=>{ loadLocations(); }, []);
  useEffect(()=>{ if (locationId) loadFloors(locationId); }, [locationId]);
  useEffect(()=>{ if (locationId && floorId) loadTables(locationId, floorId); }, [locationId, floorId]);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-800 mb-2">Quản lý bàn</h1>
        <p className="text-gray-600">Theo dõi trạng thái các bàn trong quán</p>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm">
        <div className="flex flex-wrap items-center gap-4">
          <div className="flex-1 min-w-48">
            <label className="block text-sm font-medium text-gray-700 mb-2">Chọn khu vực</label>
            <select 
              value={locationId || ''} 
              onChange={e=>setLocationId(Number(e.target.value))}
              className="w-full border border-gray-300 rounded-xl px-4 py-3 focus:ring-2 focus:ring-amber-500 focus:border-transparent transition-all duration-200"
            >
              {locations.map(l=><option key={l.id} value={l.id}>{l.name}</option>)}
            </select>
          </div>
          <div className="flex-1 min-w-48">
            <label className="block text-sm font-medium text-gray-700 mb-2">Chọn tầng</label>
            <select 
              value={floorId || ''} 
              onChange={e=>setFloorId(Number(e.target.value))}
              className="w-full border border-gray-300 rounded-xl px-4 py-3 focus:ring-2 focus:ring-amber-500 focus:border-transparent transition-all duration-200"
            >
              {floors.map(f=><option key={f.id} value={f.id}>{f.name}</option>)}
            </select>
          </div>
        </div>
      </div>

      {/* Tables Grid */}
      <TableGrid tables={tables} onTableUpdate={handleTableUpdate} token={token} />
    </div>
  )
}
