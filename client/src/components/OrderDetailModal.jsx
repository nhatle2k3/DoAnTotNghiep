import React, { useEffect, useState } from 'react';
import { api } from '../api';
import PaymentModal from './PaymentModal';

export default function OrderDetailModal({ orderId, isOpen, onClose, onOrderUpdate, token }) {
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(false);
  const [updating, setUpdating] = useState(false);
  const [showPayment, setShowPayment] = useState(false);
  const [selectedStatus, setSelectedStatus] = useState('');
  
  // Get token from localStorage if not provided as prop
  const getToken = () => {
    const authToken = token || localStorage.getItem('token');
    if (!authToken) {
      console.warn('No token found in props or localStorage');
    }
    return authToken;
  };

  useEffect(() => {
    if (isOpen && orderId) {
      loadOrderDetails();
    }
  }, [isOpen, orderId]);

  const loadOrderDetails = async () => {
    setLoading(true);
    setSelectedStatus(''); // Reset status selection
    try {
      const data = await api(`/orders/${orderId}`);
      setOrder(data);
    } catch (error) {
      console.error('Error loading order details:', error);
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status) => {
    switch(status) {
      case 'pending': return 'bg-yellow-100 text-yellow-800 border-yellow-200';
      case 'preparing': return 'bg-blue-100 text-blue-800 border-blue-200';
      case 'ready': return 'bg-green-100 text-green-800 border-green-200';
      case 'served': return 'bg-purple-100 text-purple-800 border-purple-200';
      case 'paid': return 'bg-gray-100 text-gray-800 border-gray-200';
      case 'cancelled': return 'bg-red-100 text-red-800 border-red-200';
      default: return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const getStatusIcon = (status) => {
    switch(status) {
      case 'pending': return '⏳';
      case 'preparing': return '👨‍🍳';
      case 'ready': return '✅';
      case 'served': return '🍽️';
      case 'paid': return '💰';
      case 'cancelled': return '❌';
      default: return '❓';
    }
  };

  const getStatusLabel = (status) => {
    switch(status) {
      case 'pending': return 'Chờ xử lý';
      case 'preparing': return 'Đang chuẩn bị';
      case 'ready': return 'Sẵn sàng';
      case 'served': return 'Đã phục vụ';
      case 'paid': return 'Đã thanh toán';
      case 'cancelled': return 'Đã hủy';
      default: return 'Không xác định';
    }
  };

  const getAllStatuses = () => {
    return [
      { value: 'pending', label: 'Chờ xử lý', icon: '⏳' },
      { value: 'preparing', label: 'Đang chuẩn bị', icon: '👨‍🍳' },
      { value: 'ready', label: 'Sẵn sàng', icon: '✅' },
      { value: 'served', label: 'Đã phục vụ', icon: '🍽️' },
      { value: 'paid', label: 'Đã thanh toán', icon: '💰' },
      { value: 'cancelled', label: 'Đã hủy', icon: '❌' }
    ];
  };

  const getAvailableStatuses = (currentStatus) => {
    // Admin can change to any status except the current one
    return getAllStatuses().filter(s => s.value !== currentStatus);
  };

  const getNextStatus = (currentStatus) => {
    switch(currentStatus) {
      case 'pending': return 'preparing';
      case 'preparing': return 'ready';
      case 'ready': return 'served';
      default: return null;
    }
  };

  const getNextStatusLabel = (currentStatus) => {
    switch(currentStatus) {
      case 'pending': return 'Bắt đầu chuẩn bị';
      case 'preparing': return 'Hoàn thành';
      case 'ready': return 'Đã phục vụ';
      default: return null;
    }
  };

  const handleStatusUpdate = async (newStatus = null) => {
    if (!order) return;
    
    const statusToUpdate = newStatus || getNextStatus(order.status);
    if (!statusToUpdate) {
      alert('Vui lòng chọn trạng thái để cập nhật');
      return;
    }

    // Confirm for critical status changes
    if (statusToUpdate === 'cancelled') {
      const confirmed = window.confirm('Bạn có chắc chắn muốn hủy đơn hàng này? Hành động này không thể hoàn tác.');
      if (!confirmed) return;
    }

    setUpdating(true);
    try {
      const authToken = getToken();
      if (!authToken) {
        throw new Error('Không tìm thấy token xác thực. Vui lòng đăng nhập lại.');
      }
      
      console.log('Updating order status:', { orderId: order.id, statusToUpdate, hasToken: !!authToken });
      
      // api() returns JSON data directly on success, or throws error on failure
      const result = await api(`/orders/${order.id}/status`, {
        method: 'PUT',
        body: { status: statusToUpdate },
        token: authToken
      });
      
      // If we get here, the update was successful
      console.log('Order status updated successfully:', result);
      
      // Update local state
      setOrder(prev => ({ ...prev, status: statusToUpdate }));
      setSelectedStatus(''); // Reset selection
      
      // Notify parent component
      if (onOrderUpdate) {
        onOrderUpdate();
      }
      
      // Show success message
      alert(`✅ Đã cập nhật trạng thái đơn hàng thành: ${getStatusLabel(statusToUpdate)}`);
    } catch (error) {
      console.error('Error updating order status:', error);
      
      // Parse error message from response
      let errorMessage = 'Có lỗi xảy ra khi cập nhật trạng thái đơn hàng';
      if (error.message) {
        errorMessage = error.message;
      } else if (error.error) {
        errorMessage = error.error;
      }
      
      // If token is invalid or expired, suggest re-login
      if (errorMessage.includes('token') || errorMessage.includes('Unauthorized') || errorMessage.includes('Invalid')) {
        const shouldReload = confirm('Phiên đăng nhập đã hết hạn hoặc không hợp lệ. Vui lòng đăng nhập lại.\n\nBạn có muốn tải lại trang để đăng nhập không?');
        if (shouldReload) {
          window.location.reload();
        }
      } else {
        alert(`Lỗi: ${errorMessage}`);
      }
    } finally {
      setUpdating(false);
    }
  };

  const handlePaymentSuccess = () => {
    // Reload order details after payment
    loadOrderDetails();
    if (onOrderUpdate) {
      onOrderUpdate();
    }
  };

  if (!isOpen) return null;

  const handleBackdropClick = (e) => {
    // Only close if clicking the backdrop itself, not the modal content
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  return (
    <div 
      className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      onClick={handleBackdropClick}
    >
      <div 
        className="bg-white rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-hidden shadow-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="bg-gradient-to-r from-amber-500 to-orange-500 p-6 text-white">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-2xl font-bold">Chi tiết đơn hàng</h2>
              <p className="text-amber-100">ID: #{orderId}</p>
            </div>
            <button
              type="button"
              onClick={onClose}
              className="text-white hover:text-amber-200 transition-colors duration-200"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6 overflow-y-auto max-h-[calc(90vh-120px)]">
          {loading ? (
            <div className="text-center py-12">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-amber-500 mx-auto mb-4"></div>
              <p className="text-gray-600">Đang tải chi tiết đơn hàng...</p>
            </div>
          ) : order ? (
            <div className="space-y-6">
              {/* Order Info */}
              <div className="bg-gray-50 rounded-xl p-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm text-gray-600">Bàn</p>
                    <p className="text-lg font-semibold text-gray-800">Bàn {order.table_number}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Trạng thái</p>
                    <div className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium border ${getStatusColor(order.status)}`}>
                      <span className="mr-1">{getStatusIcon(order.status)}</span>
                      {getStatusLabel(order.status)}
                    </div>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Thời gian tạo</p>
                    <p className="text-sm font-medium text-gray-800">
                      {new Date(order.created_at).toLocaleString('vi-VN')}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Tổng tiền</p>
                    <p className="text-lg font-bold text-amber-600">
                      {(order.total/1000).toFixed(0)}k VNĐ
                    </p>
                  </div>
                </div>
              </div>

              {/* Order Items */}
              <div>
                <h3 className="text-lg font-semibold text-gray-800 mb-4 flex items-center">
                  <span className="mr-2">🍽️</span>
                  Món đã đặt ({order.items?.length || 0})
                </h3>
                
                {order.items && order.items.length > 0 ? (
                  <div className="space-y-3">
                    {order.items.map((item, index) => (
                      <div key={index} className="bg-white border border-gray-200 rounded-xl p-4 hover:shadow-md transition-shadow duration-200">
                        <div className="flex items-center justify-between">
                          <div className="flex-1">
                            <h4 className="font-semibold text-gray-800">{item.name}</h4>
                            {item.description && (
                              <p className="text-sm text-gray-600 mt-1">{item.description}</p>
                            )}
                            <div className="flex items-center space-x-4 mt-2">
                              <span className="text-sm text-gray-600">
                                Số lượng: <span className="font-medium">{item.quantity}</span>
                              </span>
                              <span className="text-sm text-gray-600">
                                Đơn giá: <span className="font-medium">{(item.price/1000).toFixed(0)}k VNĐ</span>
                              </span>
                            </div>
                          </div>
                          <div className="text-right">
                            <p className="text-lg font-bold text-amber-600">
                              {((item.price * item.quantity)/1000).toFixed(0)}k VNĐ
                            </p>
                            <p className="text-xs text-gray-500">Thành tiền</p>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8 bg-gray-50 rounded-xl">
                    <div className="text-4xl mb-3">🍽️</div>
                    <p className="text-gray-500">Chưa có món nào trong đơn hàng</p>
                  </div>
                )}
              </div>

              {/* Order Summary */}
              <div className="bg-gradient-to-r from-amber-50 to-orange-50 rounded-xl p-4 border border-amber-200">
                <div className="flex justify-between items-center">
                  <span className="text-lg font-semibold text-gray-800">Tổng cộng:</span>
                  <span className="text-2xl font-bold text-amber-600">
                    {(order.total/1000).toFixed(0)}k VNĐ
                  </span>
                </div>
              </div>

              {/* Status Management Section */}
              {order.status !== 'paid' && order.status !== 'cancelled' && (
                <div className="bg-white border-2 border-amber-200 rounded-xl p-6">
                  <h3 className="text-lg font-semibold text-gray-800 mb-4 flex items-center">
                    <span className="mr-2">⚙️</span>
                    Xử lý đơn hàng
                  </h3>
                  
                  <div className="space-y-4">
                    {/* Quick Action - Next Status */}
                    {getNextStatus(order.status) && (
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                          Thao tác nhanh
                        </label>
                        <button
                          type="button"
                          onClick={() => handleStatusUpdate()}
                          disabled={updating}
                          className="w-full px-4 py-3 bg-gradient-to-r from-amber-500 to-orange-500 text-white rounded-lg hover:from-amber-600 hover:to-orange-600 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2 font-semibold"
                        >
                          {updating ? (
                            <>
                              <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                              <span>Đang cập nhật...</span>
                            </>
                          ) : (
                            <>
                              <span>🔄</span>
                              <span>Chuyển sang: {getStatusLabel(getNextStatus(order.status))}</span>
                            </>
                          )}
                        </button>
                      </div>
                    )}

                    {/* Custom Status Selection */}
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Hoặc chọn trạng thái khác
                      </label>
                      <select
                        value={selectedStatus}
                        onChange={(e) => setSelectedStatus(e.target.value)}
                        disabled={updating}
                        className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-transparent disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        <option value="">-- Chọn trạng thái --</option>
                        {getAvailableStatuses(order.status).map(status => (
                          <option key={status.value} value={status.value}>
                            {status.icon} {status.label}
                          </option>
                        ))}
                      </select>
                      {selectedStatus && (
                        <button
                          type="button"
                          onClick={() => handleStatusUpdate(selectedStatus)}
                          disabled={updating}
                          className="w-full mt-3 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2"
                        >
                          {updating ? (
                            <>
                              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                              <span>Đang cập nhật...</span>
                            </>
                          ) : (
                            <>
                              <span>✓</span>
                              <span>Cập nhật thành: {getStatusLabel(selectedStatus)}</span>
                            </>
                          )}
                        </button>
                      )}
                    </div>

                    {/* Cancel Order Button */}
                    {order.status !== 'cancelled' && (
                      <div>
                        <button
                          type="button"
                          onClick={() => handleStatusUpdate('cancelled')}
                          disabled={updating}
                          className="w-full px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2 font-medium"
                        >
                          {updating ? (
                            <>
                              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                              <span>Đang xử lý...</span>
                            </>
                          ) : (
                            <>
                              <span>❌</span>
                              <span>Hủy đơn hàng</span>
                            </>
                          )}
                        </button>
                      </div>
                    )}
                  </div>
                </div>
              )}
            </div>
          ) : (
            <div className="text-center py-12">
              <div className="text-4xl mb-4">❌</div>
              <h3 className="text-lg font-medium text-gray-500 mb-2">Không thể tải đơn hàng</h3>
              <p className="text-gray-400">Vui lòng thử lại sau</p>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="bg-gray-50 px-6 py-4 flex justify-between items-center">
          <div className="text-sm text-gray-500">
            {order && (
              <span>
                Trạng thái hiện tại: <strong className="text-gray-700">{getStatusLabel(order.status)}</strong>
              </span>
            )}
          </div>
          <div className="flex space-x-3">
            {order && order.status === 'served' && (
              <button
                type="button"
                onClick={() => setShowPayment(true)}
                className="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors duration-200 flex items-center space-x-2"
              >
                <span>💳</span>
                <span>Thanh toán</span>
              </button>
            )}
            <button
              type="button"
              onClick={onClose}
              className="px-6 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors duration-200 font-medium"
            >
              Đóng
            </button>
          </div>
        </div>
      </div>

      {/* Payment Modal */}
      <PaymentModal
        order={order}
        isOpen={showPayment}
        onClose={() => setShowPayment(false)}
        onPaymentSuccess={handlePaymentSuccess}
        token={getToken()}
      />
    </div>
  );
}
