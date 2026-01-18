import React, { useEffect, useState } from 'react';
import { api } from '../api';
import OrderDetailModal from '../components/OrderDetailModal';
import { io } from 'socket.io-client';
import { useNotification } from '../contexts/NotificationContext';

export default function Orders({ token }) {
  const [orders, setOrders] = useState([]);
  const [selectedOrderId, setSelectedOrderId] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const { showSuccess, showInfo } = useNotification();
  
  // Get token from localStorage if not provided as prop
  const getToken = () => {
    return token || localStorage.getItem('token');
  };
  
  const load = async ()=>{
    try {
    const data = await api('/orders/open');
      console.log('📦 Orders loaded:', data);
      if (data.length > 0) {
        console.log('📦 Sample order data:', data[0]);
      }
    setOrders(data);
    } catch (e) {
      console.error('❌ Error loading orders:', e);
    }
  };
  
  useEffect(()=>{ 
    load(); 
    
    // Connect to WebSocket for real-time updates
    const API_BASE = import.meta.env.VITE_API_BASE || `${location.protocol}//${location.hostname}:4000/api`;
    const socketUrl = API_BASE.replace('/api', '');
    console.log('🔌 Connecting to WebSocket:', socketUrl);
    
    const socket = io(socketUrl, {
      transports: ['websocket', 'polling'],
      autoConnect: true,
      reconnection: true,
      reconnectionDelay: 1000,
      reconnectionAttempts: 5
    });
    
    socket.on('connect', () => {
      console.log('🔗 Connected to WebSocket:', socket.id);
      socket.emit('join-admin');
    });
    
    socket.on('new-order', (newOrder) => {
      console.log('📦 New order received:', newOrder);
      setOrders(prev => {
        // Check if order already exists to avoid duplicates
        const exists = prev.find(o => o.id === newOrder.id);
        if (exists) return prev;
        return [newOrder, ...prev];
      });
      showInfo(`🆕 Đơn hàng mới từ Bàn ${newOrder.table_number} - ${(newOrder.total/1000).toFixed(0)}k VNĐ`);
    });
    
    socket.on('order-status-updated', (orderUpdate) => {
      console.log('🔄 Order status update received:', orderUpdate);
      setOrders(prev => prev.map(order => 
        order.id === orderUpdate.id 
          ? { ...order, status: orderUpdate.newStatus }
          : order
      ));
      showInfo(`🔄 Đơn hàng #${orderUpdate.id} (Bàn ${orderUpdate.table_number}) đã chuyển từ ${orderUpdate.oldStatus} sang ${orderUpdate.newStatus}`);
    });
    
    socket.on('payment-completed', (paymentData) => {
      console.log('💰 Payment completed received:', paymentData);
      setOrders(prev => prev.map(order => 
        order.id === paymentData.orderId 
          ? { ...order, status: 'paid' }
          : order
      ));
      showInfo(`💰 Thanh toán thành công! Đơn hàng #${paymentData.orderId} (Bàn ${paymentData.tableNumber}) - ${(paymentData.amount/1000).toFixed(0)}k VNĐ - ${paymentData.method}`);
    });
    
    socket.on('connect_error', (error) => {
      console.error('❌ WebSocket connection error:', error);
    });
    
    socket.on('disconnect', (reason) => {
      console.log('🔌 Disconnected from WebSocket:', reason);
    });
    
    return () => {
      console.log('🧹 Cleaning up WebSocket connection');
      socket.disconnect();
    };
  }, [showInfo]);

  const handleViewDetails = (orderId) => {
    setSelectedOrderId(orderId);
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setSelectedOrderId(null);
  };

    const handleOrderUpdate = () => {
    // Reload orders when status is updated
    load();
  };

  // Manual refresh function for testing
  const handleRefresh = () => {
    console.log('🔄 Manual refresh triggered');
    load();
  };
  const getStatusColor = (status) => {
    switch(status) {
      case 'pending': return 'bg-yellow-100 text-yellow-800 border-yellow-200';
      case 'preparing': return 'bg-blue-100 text-blue-800 border-blue-200';
      case 'ready': return 'bg-green-100 text-green-800 border-green-200';
      case 'served': return 'bg-gray-100 text-gray-800 border-gray-200';
      default: return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const getStatusIcon = (status) => {
    switch(status) {
      case 'pending': return '⏳';
      case 'preparing': return '👨‍🍳';
      case 'ready': return '✅';
      case 'served': return '🍽️';
      default: return '❓';
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Đơn hàng đang mở</h1>
          <p className="text-gray-600 mt-1">Quản lý các đơn hàng hiện tại</p>
        </div>
        <button 
          onClick={handleRefresh} 
          className="px-4 py-2 bg-white border border-gray-300 rounded-xl hover:bg-gray-50 hover:border-gray-400 transition-all duration-200 flex items-center space-x-2 shadow-sm"
        >
          <span>🔄</span>
          <span>Làm mới</span>
        </button>
      </div>

      {/* Orders Grid */}
      {orders.length === 0 ? (
        <div className="text-center py-12">
          <div className="text-6xl mb-4">📋</div>
          <h3 className="text-lg font-medium text-gray-500 mb-2">Chưa có đơn hàng nào</h3>
          <p className="text-gray-400">Các đơn hàng mới sẽ xuất hiện ở đây</p>
        </div>
      ) : (
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {orders.map(order => (
            <div key={order.id} className="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm hover:shadow-md transition-all duration-200">
              {/* Order Header */}
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 bg-gradient-to-br from-amber-400 to-orange-500 rounded-xl flex items-center justify-center text-white font-bold">
                    {order.table_number}
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="font-semibold text-gray-800 break-words">
                      {order.location_name 
                        ? `Bàn ${order.table_number}, Chi nhánh ${order.location_name}${order.location_address ? ` - ${order.location_address}` : ''}`
                        : `Bàn ${order.table_number}`
                      }
                    </h3>
                    <p className="text-sm text-gray-500">ID: #{order.id}</p>
                  </div>
                </div>
                <div className={`px-3 py-1 rounded-full text-xs font-medium border ${getStatusColor(order.status)}`}>
                  <span className="mr-1">{getStatusIcon(order.status)}</span>
                  {order.status}
                </div>
              </div>

              {/* Order Details */}
              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Tổng tiền:</span>
                  <span className="font-semibold text-lg text-gray-800">{(order.total/1000).toFixed(0)}k VNĐ</span>
                </div>
                
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Thời gian:</span>
                  <span className="text-sm text-gray-500">
                    {new Date(order.created_at).toLocaleTimeString('vi-VN')}
                  </span>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="mt-4 pt-4 border-t border-gray-100">
                <div className="flex space-x-2">
                  <button 
                    onClick={() => handleViewDetails(order.id)}
                    className="flex-1 px-3 py-2 bg-amber-500 text-white text-sm font-medium rounded-lg hover:bg-amber-600 transition-colors duration-200"
                  >
                    Xem chi tiết
                  </button>
                  <button className="px-3 py-2 bg-gray-100 text-gray-600 text-sm font-medium rounded-lg hover:bg-gray-200 transition-colors duration-200">
                    ✏️
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Order Detail Modal */}
      <OrderDetailModal
        orderId={selectedOrderId}
        isOpen={isModalOpen}
        onClose={handleCloseModal}
        onOrderUpdate={handleOrderUpdate}
        token={getToken()}
      />
    </div>
  )
}
