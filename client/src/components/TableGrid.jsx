import React, { useState } from 'react';
import { api } from '../api';

const statusConfig = (s) => {
  const configs = {
    available: { 
      bg: 'bg-emerald-50', 
      text: 'text-emerald-800', 
      border: 'border-emerald-200', 
      icon: '✅', 
      label: 'Trống',
      button: 'bg-emerald-500 hover:bg-emerald-600'
    },
    occupied: { 
      bg: 'bg-amber-50', 
      text: 'text-amber-800', 
      border: 'border-amber-200', 
      icon: '👥', 
      label: 'Có khách',
      button: 'bg-amber-500 hover:bg-amber-600'
    },
    reserved: { 
      bg: 'bg-blue-50', 
      text: 'text-blue-800', 
      border: 'border-blue-200', 
      icon: '📅', 
      label: 'Đã đặt',
      button: 'bg-blue-500 hover:bg-blue-600'
    },
    maintenance: { 
      bg: 'bg-red-50', 
      text: 'text-red-800', 
      border: 'border-red-200', 
      icon: '🔧', 
      label: 'Bảo trì',
      button: 'bg-red-500 hover:bg-red-600'
    }
  };
  return configs[s] || { 
    bg: 'bg-gray-50', 
    text: 'text-gray-800', 
    border: 'border-gray-200', 
    icon: '❓', 
    label: 'Không xác định',
    button: 'bg-gray-500 hover:bg-gray-600'
  };
};

export default function TableGrid({ tables=[], onTableUpdate, token }) {
  const [updating, setUpdating] = useState({});

  const getNextStatus = (currentStatus) => {
    switch(currentStatus) {
      case 'available': return 'occupied';
      case 'occupied': return 'available';
      case 'reserved': return 'available';
      case 'maintenance': return 'available';
      default: return 'available';
    }
  };

  const getNextStatusLabel = (currentStatus) => {
    switch(currentStatus) {
      case 'available': return 'Có khách';
      case 'occupied': return 'Trống';
      case 'reserved': return 'Hủy đặt';
      case 'maintenance': return 'Sửa xong';
      default: return 'Trống';
    }
  };

  const handleStatusUpdate = async (tableId, currentStatus) => {
    const nextStatus = getNextStatus(currentStatus);
    setUpdating(prev => ({ ...prev, [tableId]: true }));

    try {
      await api(`/tables/${tableId}/status`, {
        method: 'PUT',
        body: { status: nextStatus },
        token
      });

      if (onTableUpdate) {
        onTableUpdate();
      }
    } catch (error) {
      console.error('Error updating table status:', error);
      alert('Có lỗi xảy ra khi cập nhật trạng thái bàn');
    } finally {
      setUpdating(prev => ({ ...prev, [tableId]: false }));
    }
  };

  if (tables.length === 0) {
    return (
      <div className="text-center py-12">
        <div className="text-6xl mb-4">🪑</div>
        <h3 className="text-lg font-medium text-gray-500 mb-2">Chưa có bàn nào</h3>
        <p className="text-gray-400">Chọn khu vực và tầng để xem bàn</p>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
      {tables.map(table => {
        const config = statusConfig(table.status);
        return (
          <div key={table.id} className={`group bg-white rounded-2xl border-2 ${config.border} ${config.bg} p-6 shadow-sm hover:shadow-lg transition-all duration-300`}>
            {/* Table Header */}
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center space-x-3">
                <div className={`w-12 h-12 ${config.bg} ${config.border} border-2 rounded-xl flex items-center justify-center`}>
                  <span className="text-2xl">{config.icon}</span>
                </div>
                <div>
                  <h3 className="text-lg font-bold text-gray-800">Bàn {table.table_number}</h3>
                  <p className="text-sm text-gray-500">ID: #{table.id}</p>
                </div>
              </div>
            </div>

            {/* Status Badge */}
            <div className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${config.text} ${config.bg} ${config.border} border`}>
              <span className="mr-1">{config.icon}</span>
              {config.label}
            </div>

            {/* QR Code */}
            <div className="mt-4 p-3 bg-white rounded-xl border border-gray-200">
              <div className="text-center mb-2">
                <span className="text-xs text-gray-500">QR Code</span>
              </div>
              <div className="flex justify-center">
                <img 
                  src={table.qr_code} 
                  alt={`QR Code for Table ${table.table_number}`} 
                  className="w-20 h-20 rounded-lg shadow-sm"
                />
              </div>
            </div>

            {/* Action Buttons */}
            <div className="mt-4 space-y-2">
              <button 
                onClick={() => handleStatusUpdate(table.id, table.status)}
                disabled={updating[table.id]}
                className={`w-full px-4 py-2 ${config.button} text-white text-sm font-medium rounded-xl transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2`}
              >
                {updating[table.id] ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                    <span>Đang cập nhật...</span>
                  </>
                ) : (
                  <>
                    <span>🔄</span>
                    <span>{getNextStatusLabel(table.status)}</span>
                  </>
                )}
              </button>
              <button className="w-full px-4 py-2 bg-gray-100 text-gray-600 text-sm font-medium rounded-xl hover:bg-gray-200 transition-colors duration-200">
                📋 Chi tiết
              </button>
            </div>
          </div>
        );
      })}
    </div>
  )
}
