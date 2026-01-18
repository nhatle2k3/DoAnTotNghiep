/**
 * Component hiển thị chi tiết đơn hàng và cho phép quản lý trạng thái đơn hàng
 * - Hiển thị thông tin đơn hàng: bàn, trạng thái, món đã đặt, tổng tiền
 * - Cho phép admin cập nhật trạng thái đơn hàng (pending, preparing, ready, served, paid, cancelled)
 * - Cho phép thanh toán khi đơn hàng ở trạng thái "served"
 */
import React, { useEffect, useState } from 'react';
import { api } from '../api';
import PaymentModal from './PaymentModal';

export default function OrderDetailModal({ orderId, isOpen, onClose, onOrderUpdate, token }) {
  // State quản lý dữ liệu đơn hàng
  const [order, setOrder] = useState(null); // Thông tin đơn hàng hiện tại
  const [loading, setLoading] = useState(false); // Trạng thái đang tải dữ liệu
  const [updating, setUpdating] = useState(false); // Trạng thái đang cập nhật
  const [showPayment, setShowPayment] = useState(false); // Hiển thị modal thanh toán
  const [selectedStatus, setSelectedStatus] = useState(''); // Trạng thái được chọn từ dropdown
  
  /**
   * Lấy token xác thực từ localStorage nếu không được truyền qua props
   * @returns {string|null} Token xác thực hoặc null
   */
  const getToken = () => {
    const authToken = token || localStorage.getItem('token');
    if (!authToken) {
      console.warn('No token found in props or localStorage');
    }
    return authToken;
  };

  /**
   * Effect: Tải chi tiết đơn hàng khi modal được mở
   */
  useEffect(() => {
    if (isOpen && orderId) {
      loadOrderDetails();
    }
  }, [isOpen, orderId]);

  /**
   * Tải chi tiết đơn hàng từ API
   */
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

  /**
   * Trả về màu sắc CSS tương ứng với trạng thái đơn hàng
   * @param {string} status - Trạng thái đơn hàng
   * @returns {string} Các class CSS cho màu sắc
   */
  const getStatusColor = (status) => {
    switch(status) {
      case 'pending': return 'bg-yellow-100 text-yellow-800 border-yellow-200'; // Chờ xử lý - vàng
      case 'preparing': return 'bg-blue-100 text-blue-800 border-blue-200'; // Đang chuẩn bị - xanh dương
      case 'ready': return 'bg-green-100 text-green-800 border-green-200'; // Sẵn sàng - xanh lá
      case 'served': return 'bg-purple-100 text-purple-800 border-purple-200'; // Đã phục vụ - tím
      case 'paid': return 'bg-gray-100 text-gray-800 border-gray-200'; // Đã thanh toán - xám
      case 'cancelled': return 'bg-red-100 text-red-800 border-red-200'; // Đã hủy - đỏ
      default: return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  /**
   * Trả về icon emoji tương ứng với trạng thái đơn hàng
   * @param {string} status - Trạng thái đơn hàng
   * @returns {string} Icon emoji
   */
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

  /**
   * Trả về nhãn tiếng Việt tương ứng với trạng thái đơn hàng
   * @param {string} status - Trạng thái đơn hàng
   * @returns {string} Nhãn tiếng Việt
   */
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

  /**
   * Trả về danh sách tất cả các trạng thái có thể có
   * @returns {Array} Mảng các object chứa value, label, icon
   */
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

  /**
   * Trả về danh sách các trạng thái có thể chuyển đổi từ trạng thái hiện tại
   * Admin có thể chuyển sang bất kỳ trạng thái nào trừ trạng thái hiện tại
   * @param {string} currentStatus - Trạng thái hiện tại của đơn hàng
   * @returns {Array} Danh sách các trạng thái có thể chuyển đổi
   */
  const getAvailableStatuses = (currentStatus) => {
    return getAllStatuses().filter(s => s.value !== currentStatus);
  };

  /**
   * Trả về trạng thái tiếp theo trong quy trình xử lý đơn hàng
   * @param {string} currentStatus - Trạng thái hiện tại
   * @returns {string|null} Trạng thái tiếp theo hoặc null nếu không có
   */
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

  /**
   * Xử lý cập nhật trạng thái đơn hàng
   * @param {string|null} newStatus - Trạng thái mới (nếu null sẽ dùng trạng thái tiếp theo)
   */
  const handleStatusUpdate = async (newStatus = null) => {
    if (!order) return;
    
    // Xác định trạng thái cần cập nhật
    const statusToUpdate = newStatus || getNextStatus(order.status);
    if (!statusToUpdate) {
      alert('Vui lòng chọn trạng thái để cập nhật');
      return;
    }

    // Xác nhận trước khi hủy đơn hàng (hành động không thể hoàn tác)
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
      
      // Gọi API để cập nhật trạng thái đơn hàng
      // api() trả về JSON data khi thành công, hoặc throw error khi thất bại
      const result = await api(`/orders/${order.id}/status`, {
        method: 'PUT',
        body: { status: statusToUpdate },
        token: authToken
      });
      
      // Nếu đến đây, cập nhật đã thành công
      console.log('Order status updated successfully:', result);
      
      // Cập nhật state local
      setOrder(prev => ({ ...prev, status: statusToUpdate }));
      setSelectedStatus(''); // Reset lựa chọn
      
      // Thông báo cho component cha để cập nhật danh sách đơn hàng
      if (onOrderUpdate) {
        onOrderUpdate();
      }
      
      // Hiển thị thông báo thành công
      alert(`✅ Đã cập nhật trạng thái đơn hàng thành: ${getStatusLabel(statusToUpdate)}`);
    } catch (error) {
      console.error('Error updating order status:', error);
      
      // Phân tích thông báo lỗi từ response
      let errorMessage = 'Có lỗi xảy ra khi cập nhật trạng thái đơn hàng';
      if (error.message) {
        errorMessage = error.message;
      } else if (error.error) {
        errorMessage = error.error;
      }
      
      // Nếu token không hợp lệ hoặc hết hạn, đề xuất đăng nhập lại
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

  /**
   * Xử lý khi thanh toán thành công
   * Tải lại chi tiết đơn hàng và thông báo component cha
   */
  const handlePaymentSuccess = () => {
    loadOrderDetails();
    if (onOrderUpdate) {
      onOrderUpdate();
    }
  };

  // Không hiển thị nếu modal không mở
  if (!isOpen) return null;

  /**
   * Xử lý click vào backdrop (nền mờ) để đóng modal
   * Chỉ đóng khi click vào backdrop, không đóng khi click vào nội dung modal
   */
  const handleBackdropClick = (e) => {
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
