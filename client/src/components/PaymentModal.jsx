import React, { useState } from 'react';
import { api } from '../api';
import { useNotification } from '../contexts/NotificationContext';

export default function PaymentModal({ order, isOpen, onClose, onPaymentSuccess, token }) {
  const [paymentMethod, setPaymentMethod] = useState('cash');
  const [processing, setProcessing] = useState(false);
  const { showSuccess, showError } = useNotification();

  const paymentMethods = [
    { id: 'cash', name: 'Tiền mặt', icon: '💵' },
    { id: 'card', name: 'Thẻ', icon: '💳' },
    { id: 'ewallet', name: 'Ví điện tử', icon: '📱' }
  ];

  const handlePayment = async () => {
    if (!order) return;

    // Check if order can be paid
    if (!['served', 'ready'].includes(order.status)) {
      showError(`Không thể thanh toán đơn hàng này. Trạng thái hiện tại: ${order.status}. Đơn hàng phải ở trạng thái "served" hoặc "ready" để có thể thanh toán.`);
      return;
    }

    setProcessing(true);
    try {
      const result = await api('/payments', {
        method: 'POST',
        body: {
          order_id: order.id,
          method: paymentMethod
        },
        token: token
      });

      showSuccess(`Thanh toán thành công! Phương thức: ${paymentMethods.find(m => m.id === paymentMethod)?.name} - Số tiền: ${(order.total/1000).toFixed(0)}k VNĐ`);
      
      if (onPaymentSuccess) {
        onPaymentSuccess();
      }
      
      onClose();
    } catch (error) {
      console.error('Payment error:', error);
      
      // Parse error message from response
      let errorMessage = 'Có lỗi xảy ra khi thanh toán';
      if (error.message) {
        errorMessage = error.message;
      } else if (error.error) {
        errorMessage = error.error;
      }
      
      showError(`Lỗi thanh toán: ${errorMessage}`);
    } finally {
      setProcessing(false);
    }
  };

  if (!isOpen || !order) return null;

  const handleBackdropClick = (e) => {
    // Only close if clicking the backdrop itself, not the modal content
    if (e.target === e.currentTarget && !processing) {
      onClose();
    }
  };

  return (
    <div 
      className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      onClick={handleBackdropClick}
    >
      <div 
        className="bg-white rounded-2xl max-w-md w-full shadow-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="bg-gradient-to-r from-green-500 to-emerald-500 p-6 text-white rounded-t-2xl">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-xl font-bold">Thanh toán đơn hàng</h2>
              <p className="text-green-100">Bàn {order.table_number} - ID: #{order.id}</p>
            </div>
            <button
              type="button"
              onClick={onClose}
              disabled={processing}
              className="text-white hover:text-green-200 transition-colors duration-200 disabled:opacity-50"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          {/* Order Summary */}
          <div className={`rounded-xl p-4 mb-6 ${
            ['served', 'ready'].includes(order.status) 
              ? 'bg-green-50 border border-green-200' 
              : 'bg-yellow-50 border border-yellow-200'
          }`}>
            <h3 className="font-semibold text-gray-800 mb-3">Tóm tắt đơn hàng</h3>
            <div className="space-y-2">
              <div className="flex justify-between">
                <span className="text-gray-600">Số món:</span>
                <span className="font-medium">{order.items?.length || 0}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Trạng thái:</span>
                <span className={`font-medium capitalize px-2 py-1 rounded-full text-xs ${
                  ['served', 'ready'].includes(order.status)
                    ? 'bg-green-100 text-green-800'
                    : 'bg-yellow-100 text-yellow-800'
                }`}>
                  {order.status}
                </span>
              </div>
              {!['served', 'ready'].includes(order.status) && (
                <div className="bg-yellow-100 border border-yellow-300 rounded-lg p-3">
                  <div className="flex items-center space-x-2">
                    <span className="text-yellow-600">⚠️</span>
                    <span className="text-sm text-yellow-800">
                      Đơn hàng phải ở trạng thái "served" hoặc "ready" để có thể thanh toán
                    </span>
                  </div>
                </div>
              )}
              <div className="border-t pt-2">
                <div className="flex justify-between text-lg font-bold">
                  <span>Tổng cộng:</span>
                  <span className="text-green-600">{(order.total/1000).toFixed(0)}k VNĐ</span>
                </div>
              </div>
            </div>
          </div>

          {/* Payment Method Selection */}
          <div className="mb-6">
            <h3 className="font-semibold text-gray-800 mb-4">Chọn phương thức thanh toán</h3>
            <div className="space-y-3">
              {paymentMethods.map(method => (
                <label
                  key={method.id}
                  className={`flex items-center p-4 border-2 rounded-xl cursor-pointer transition-all duration-200 ${
                    paymentMethod === method.id
                      ? 'border-green-500 bg-green-50'
                      : 'border-gray-200 hover:border-gray-300'
                  }`}
                >
                  <input
                    type="radio"
                    name="paymentMethod"
                    value={method.id}
                    checked={paymentMethod === method.id}
                    onChange={(e) => setPaymentMethod(e.target.value)}
                    className="sr-only"
                  />
                  <div className="flex items-center space-x-3">
                    <span className="text-2xl">{method.icon}</span>
                    <span className="font-medium text-gray-800">{method.name}</span>
                  </div>
                  {paymentMethod === method.id && (
                    <div className="ml-auto">
                      <div className="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center">
                        <svg className="w-4 h-4 text-white" fill="currentColor" viewBox="0 0 20 20">
                          <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                        </svg>
                      </div>
                    </div>
                  )}
                </label>
              ))}
            </div>
          </div>

          {/* Payment Amount */}
          <div className="bg-gradient-to-r from-green-50 to-emerald-50 rounded-xl p-4 mb-6 border border-green-200">
            <div className="text-center">
              <p className="text-sm text-gray-600 mb-1">Số tiền cần thanh toán</p>
              <p className="text-3xl font-bold text-green-600">
                {(order.total/1000).toFixed(0)}k VNĐ
              </p>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="bg-gray-50 px-6 py-4 rounded-b-2xl flex justify-end space-x-3">
          <button
            type="button"
            onClick={onClose}
            className="px-4 py-2 text-gray-600 hover:text-gray-800 transition-colors duration-200"
            disabled={processing}
          >
            Hủy
          </button>
          <button
            type="button"
            onClick={handlePayment}
            disabled={processing || !['served', 'ready'].includes(order.status)}
            className={`px-6 py-2 font-semibold rounded-lg transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center space-x-2 ${
              ['served', 'ready'].includes(order.status)
                ? 'bg-green-500 text-white hover:bg-green-600'
                : 'bg-gray-300 text-gray-500 cursor-not-allowed'
            }`}
          >
            {processing ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                <span>Đang xử lý...</span>
              </>
            ) : (
              <>
                <span>💳</span>
                <span>Thanh toán</span>
              </>
            )}
          </button>
        </div>
      </div>
    </div>
  );
}
