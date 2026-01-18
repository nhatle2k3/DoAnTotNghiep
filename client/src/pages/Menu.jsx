/**
 * Component trang thực đơn - cho phép nhân viên/admin đặt món cho khách hàng
 * - Hiển thị danh sách món ăn với tìm kiếm và lọc theo danh mục
 * - Quản lý giỏ hàng với khả năng thay đổi số lượng
 * - Tạo đơn hàng với modal chọn bàn (cho admin/staff)
 * - Floating cart icon xuất hiện khi có món trong giỏ
 */
import React, { useEffect, useState } from 'react';
import { api } from '../api';
import MenuItemCard from '../components/MenuItemCard';

export default function Menu({ token, user, onLogout }) {
  // State quản lý dữ liệu
  const [items, setItems] = useState([]); // Danh sách món ăn
  const [cart, setCart] = useState([]); // Giỏ hàng: [{item_id, name, price, quantity}]
  const [searchTerm, setSearchTerm] = useState(''); // Từ khóa tìm kiếm
  const [selectedCategory, setSelectedCategory] = useState(''); // Danh mục được chọn
  const [categories, setCategories] = useState([]); // Danh sách danh mục
  const [cartOpen, setCartOpen] = useState(false); // Trạng thái mở/đóng giỏ hàng
  const [showTableModal, setShowTableModal] = useState(false); // Hiển thị modal chọn bàn
  const [locations, setLocations] = useState([]); // Danh sách chi nhánh
  const [tables, setTables] = useState([]); // Danh sách bàn
  const [selectedLocation, setSelectedLocation] = useState(null); // Chi nhánh được chọn
  const [selectedTable, setSelectedTable] = useState(null); // Bàn được chọn

  /**
   * Tải danh sách món ăn từ API
   */
  const load = async ()=>{
    const data = await api('/menu');
    setItems(data);
  };

  /**
   * Tải danh sách danh mục từ API
   */
  const loadCategories = async () => {
    const data = await api('/menu/categories');
    setCategories(data);
  };

  /**
   * Effect: Tải dữ liệu khi component mount
   * - Tải món ăn và danh mục
   * - Tải chi nhánh nếu là admin/staff
   */
  useEffect(()=>{ 
    load(); 
    loadCategories();
    if (user?.role === 'admin' || user?.role === 'staff') {
      loadLocations();
    }
  }, []);

  /**
   * Tải danh sách chi nhánh từ API (chỉ cho admin/staff)
   */
  const loadLocations = async () => {
    try {
      const data = await api('/tables/locations', { token });
      setLocations(data);
      if (data.length > 0) {
        setSelectedLocation(data[0].id);
        loadTables(data[0].id);
      }
    } catch (e) {
      console.error('Failed to load locations:', e);
    }
  };

  /**
   * Tải danh sách bàn theo chi nhánh
   * @param {number} locationId - ID chi nhánh
   */
  const loadTables = async (locationId) => {
    try {
      const data = await api(`/tables?location_id=${locationId}`, { token });
      setTables(data);
    } catch (e) {
      console.error('Failed to load tables:', e);
    }
  };

  /**
   * Effect: Tải lại danh sách bàn khi chi nhánh thay đổi
   */
  useEffect(() => {
    if (selectedLocation) {
      loadTables(selectedLocation);
    }
  }, [selectedLocation]);

  /**
   * Thêm món vào giỏ hàng
   * Nếu món đã có trong giỏ, tăng số lượng lên 1
   * @param {Object} item - Thông tin món ăn
   */
  const add = (item)=>{
    setCart(c => {
      const found = c.find(x=>x.item_id===item.id);
      if (found) return c.map(x=> x.item_id===item.id ? {...x, quantity: x.quantity+1} : x);
      return [...c, { item_id: item.id, name: item.name, price: item.price, quantity: 1 }];
    });
  };

  /**
   * Cập nhật số lượng món trong giỏ hàng
   * @param {number} itemId - ID món ăn
   * @param {number} change - Số lượng thay đổi (+1 hoặc -1)
   */
  const updateQuantity = (itemId, change) => {
    setCart(c => {
      const found = c.find(x => x.item_id === itemId);
      if (!found) return c;
      
      const newQuantity = found.quantity + change;
      // Nếu số lượng <= 0, xóa món khỏi giỏ hàng
      if (newQuantity <= 0) {
        return c.filter(x => x.item_id !== itemId);
      }
      return c.map(x => x.item_id === itemId ? { ...x, quantity: newQuantity } : x);
    });
  };

  /**
   * Xóa món khỏi giỏ hàng
   * @param {number} itemId - ID món ăn
   */
  const removeFromCart = (itemId) => {
    setCart(c => c.filter(x => x.item_id !== itemId));
  };

  // Tính tổng tiền và tổng số lượng món trong giỏ hàng
  const total = cart.reduce((s,x)=>s + x.price*x.quantity, 0);
  const cartItemCount = cart.reduce((s, x) => s + x.quantity, 0);

  /**
   * Lọc danh sách món ăn theo từ khóa tìm kiếm và danh mục
   */
  const filteredItems = items.filter(item => {
    const matchesSearch = item.name.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = !selectedCategory || item.category_id.toString() === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  /**
   * Xử lý tạo đơn hàng
   * - Admin/Staff: hiển thị modal chọn bàn
   * - Customer: dùng prompt nhập ID bàn (cách cũ)
   */
  const handleCreateOrder = () => {
    if (cart.length === 0) {
      alert('Giỏ hàng trống. Vui lòng thêm món vào giỏ hàng.');
      return;
    }
    
    // Cho admin/staff: hiển thị modal chọn bàn
    if (user?.role === 'admin' || user?.role === 'staff') {
      setShowTableModal(true);
    } else {
      // Cho khách hàng: dùng prompt (cách cũ)
      createOrderWithPrompt();
    }
  };

  /**
   * Tạo đơn hàng với prompt nhập ID bàn (cho khách hàng)
   */
  const createOrderWithPrompt = async () => {
    const table_id = prompt('Nhập ID bàn (ví dụ 1):');
    if (!table_id) return;
    try {
      const res = await api('/orders', { 
        method:'POST', 
        body:{ 
          table_id: Number(table_id), 
          items: cart.map(({item_id, quantity})=>({item_id, quantity})) 
        },
        token
      });
      alert('Tạo đơn thành công. Tổng: ' + (res.total/1000).toFixed(0) + 'k VNĐ');
      setCart([]);
      setCartOpen(false);
    } catch (e) {
      alert('Lỗi: ' + e.message);
    }
  };

  /**
   * Tạo đơn hàng với bàn đã chọn (cho admin/staff)
   * Gọi API tạo đơn, cập nhật trạng thái bàn, và reset giỏ hàng
   */
  const createOrder = async () => {
    if (!selectedTable) {
      alert('Vui lòng chọn bàn');
      return;
    }

    try {
      // Gọi API tạo đơn hàng
      const res = await api('/orders', { 
        method:'POST', 
        body:{ 
          table_id: selectedTable.id, 
          items: cart.map(({item_id, quantity})=>({item_id, quantity})) 
        },
        token
      });
      
      // Hiển thị thông báo thành công với thông tin chi nhánh và bàn
      const locationName = locations.find(l => l.id === selectedLocation)?.name || 'Không xác định';
      alert(`✅ Tạo đơn thành công!\n\n📋 Chi nhánh: ${locationName}\n🪑 Bàn số: ${selectedTable.table_number}\n💰 Tổng tiền: ${(res.total/1000).toFixed(0)}k VNĐ`);
      
      // Reset state: xóa giỏ hàng, đóng modal
      setCart([]);
      setCartOpen(false);
      setShowTableModal(false);
      setSelectedTable(null);
      
      // Tải lại danh sách bàn để cập nhật trạng thái (available -> occupied)
      if (selectedLocation) {
        loadTables(selectedLocation);
      }
    } catch (e) {
      alert('Lỗi: ' + e.message);
    }
  };

  return (
    <div className="relative">
      {/* Floating Cart Icon */}
      {cartItemCount > 0 && (
        <button
          onClick={() => setCartOpen(!cartOpen)}
          className="fixed bottom-6 right-6 z-50 w-16 h-16 bg-gradient-to-r from-amber-500 to-orange-500 text-white rounded-full shadow-2xl flex items-center justify-center hover:from-amber-600 hover:to-orange-600 transform hover:scale-110 transition-all duration-200"
        >
          <div className="relative">
            <span className="text-2xl">🛒</span>
            {cartItemCount > 0 && (
              <span className="absolute -top-2 -right-2 bg-red-500 text-white text-xs font-bold rounded-full w-6 h-6 flex items-center justify-center">
                {cartItemCount > 99 ? '99+' : cartItemCount}
              </span>
            )}
          </div>
        </button>
      )}

      {/* Cart Sidebar */}
      <div className={`fixed top-0 right-0 h-full w-full sm:w-96 bg-white shadow-2xl z-40 transform transition-transform duration-300 ease-in-out ${
        cartOpen ? 'translate-x-0' : 'translate-x-full'
      }`}>
        <div className="flex flex-col h-full">
          {/* Cart Header */}
          <div className="p-6 border-b border-amber-200 bg-gradient-to-br from-amber-500 via-orange-500 to-amber-600 text-white shadow-lg">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-3">
                <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                  <span className="text-xl">🛒</span>
                </div>
                <div>
                  <h2 className="text-xl font-bold">Giỏ hàng</h2>
                  {cartItemCount > 0 && (
                    <p className="text-xs text-amber-100 mt-0.5">
                      {cartItemCount} {cartItemCount === 1 ? 'món' : 'món'}
                    </p>
                  )}
                </div>
              </div>
              <button
                onClick={() => setCartOpen(false)}
                className="w-8 h-8 flex items-center justify-center bg-white/20 hover:bg-white/30 rounded-lg transition-all duration-200 backdrop-blur-sm"
                aria-label="Đóng giỏ hàng"
              >
                <span className="text-lg">✕</span>
              </button>
            </div>
          </div>
          
          {/* Cart Items */}
          <div className="flex-1 overflow-y-auto p-6 bg-gradient-to-b from-gray-50 to-white">
            {cart.length === 0 ? (
              <div className="text-center py-16">
                <div className="w-24 h-24 mx-auto mb-6 bg-gradient-to-br from-amber-100 to-orange-100 rounded-full flex items-center justify-center">
                  <span className="text-5xl">🛒</span>
                </div>
                <h3 className="text-lg font-semibold text-gray-700 mb-2">Giỏ hàng trống</h3>
                <p className="text-gray-500 text-sm mb-6">Thêm món từ thực đơn để bắt đầu</p>
                <button
                  onClick={() => setCartOpen(false)}
                  className="px-6 py-2 bg-amber-500 text-white rounded-lg hover:bg-amber-600 transition-colors text-sm font-medium"
                >
                  Xem thực đơn
                </button>
              </div>
            ) : (
              <div className="space-y-3">
                {cart.map((item, index) => (
                  <div 
                    key={index} 
                    className="bg-white rounded-2xl p-4 border border-gray-200 shadow-sm hover:shadow-md transition-all duration-200"
                  >
                    <div className="flex items-start justify-between mb-3">
                      <div className="flex-1 min-w-0">
                        <h3 className="font-semibold text-gray-800 text-base mb-1 truncate">{item.name}</h3>
                        <div className="flex items-center space-x-2">
                          <span className="text-amber-600 font-bold text-sm">
                            {(item.price/1000).toFixed(0)}k
                          </span>
                          <span className="text-gray-400 text-xs">VNĐ</span>
                        </div>
                      </div>
                      <button
                        onClick={() => removeFromCart(item.item_id)}
                        className="ml-3 w-8 h-8 flex items-center justify-center text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-lg transition-all duration-200 flex-shrink-0"
                        aria-label="Xóa món"
                      >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                        </svg>
                      </button>
                    </div>
                    <div className="flex items-center justify-between pt-3 border-t border-gray-100">
                      <div className="flex items-center bg-gradient-to-r from-amber-50 to-orange-50 rounded-xl border border-amber-200 overflow-hidden">
                        <button
                          onClick={() => updateQuantity(item.item_id, -1)}
                          className="w-10 h-10 flex items-center justify-center text-amber-700 hover:bg-amber-200 transition-colors font-bold text-lg"
                          aria-label="Giảm số lượng"
                        >
                          −
                        </button>
                        <span className="w-12 h-10 flex items-center justify-center text-sm font-bold text-gray-800 bg-white border-x border-amber-200">
                          {item.quantity}
                        </span>
                        <button
                          onClick={() => updateQuantity(item.item_id, 1)}
                          className="w-10 h-10 flex items-center justify-center text-amber-700 hover:bg-amber-200 transition-colors font-bold text-lg"
                          aria-label="Tăng số lượng"
                        >
                          +
                        </button>
                      </div>
                      <div className="text-right ml-4">
                        <div className="text-xs text-gray-500 mb-0.5">Thành tiền</div>
                        <div className="text-lg font-bold text-amber-600">
                          {((item.price * item.quantity)/1000).toFixed(0)}k
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
          
          {/* Cart Footer */}
          {cart.length > 0 && (
            <div className="p-6 border-t-2 border-amber-200 bg-gradient-to-br from-amber-50 to-orange-50 shadow-lg">
              <div className="space-y-4">
                <div className="flex justify-between items-center pb-3 border-b border-amber-200">
                  <span className="text-lg font-semibold text-gray-700">Tổng cộng:</span>
                  <div className="text-right">
                    <div className="text-3xl font-bold text-amber-600">
                      {(total/1000).toFixed(0)}k
                    </div>
                    <div className="text-xs text-gray-500">VNĐ</div>
                  </div>
                </div>
                
              <button 
                onClick={handleCreateOrder} 
                className="w-full px-6 py-4 bg-gradient-to-r from-amber-500 to-orange-500 text-white font-bold rounded-xl hover:from-amber-600 hover:to-orange-600 transform hover:scale-[1.02] active:scale-[0.98] transition-all duration-200 shadow-lg hover:shadow-xl flex items-center justify-center space-x-2"
              >
                <span>📝</span>
                <span>Tạo đơn hàng</span>
              </button>
                
                <p className="text-xs text-center text-gray-500">
                  Nhấn để tạo đơn hàng mới
                </p>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Overlay when cart is open */}
      {cartOpen && (
        <div
          className="fixed inset-0 bg-black/50 z-30 sm:hidden"
          onClick={() => setCartOpen(false)}
        />
      )}

      {/* Table Selection Modal for Admin/Staff */}
      {showTableModal && (user?.role === 'admin' || user?.role === 'staff') && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full">
            <div className="p-6 border-b border-gray-200 bg-gradient-to-r from-amber-50 to-orange-50">
              <div className="flex items-center justify-between mb-2">
                <h2 className="text-xl font-bold text-gray-800">Chọn bàn để đặt đơn</h2>
                <button
                  onClick={() => {
                    setShowTableModal(false);
                    setSelectedTable(null);
                  }}
                  className="text-gray-400 hover:text-gray-600 transition-colors"
                >
                  ✕
                </button>
              </div>
              {selectedTable && (
                <div className="mt-3 p-3 bg-white rounded-lg border border-amber-200">
                  <div className="flex items-center space-x-2 text-sm">
                    <span className="font-semibold text-gray-700">Thông tin đơn hàng:</span>
                  </div>
                  <div className="mt-2 flex items-center space-x-4 text-sm">
                    <div className="flex items-center space-x-1">
                      <span className="text-gray-500">📍</span>
                      <span className="font-medium text-gray-800">
                        {locations.find(l => l.id === selectedLocation)?.name || 'Chưa chọn chi nhánh'}
                      </span>
                    </div>
                    <div className="flex items-center space-x-1">
                      <span className="text-gray-500">🪑</span>
                      <span className="font-medium text-gray-800">Bàn số {selectedTable.table_number}</span>
                    </div>
                  </div>
                </div>
              )}
            </div>

            <div className="p-6 space-y-4">
              {/* Location Selection */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Chọn khu vực
                </label>
                <select
                  value={selectedLocation || ''}
                  onChange={(e) => {
                    setSelectedLocation(Number(e.target.value));
                    setSelectedTable(null);
                  }}
                  className="w-full border border-gray-300 rounded-xl px-4 py-3 focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                >
                  {locations.map(loc => (
                    <option key={loc.id} value={loc.id}>{loc.name}</option>
                  ))}
                </select>
              </div>

              {/* Table Selection */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Chọn bàn
                </label>
                {tables.length === 0 ? (
                  <div className="text-center py-8 text-gray-500">
                    Không có bàn nào trong khu vực này
                  </div>
                ) : (
                  <div className="grid grid-cols-4 gap-2 max-h-64 overflow-y-auto p-2 border border-gray-200 rounded-xl">
                    {tables.map(table => {
                      const statusConfig = {
                        available: { bg: 'bg-green-100', text: 'text-green-800', label: 'Trống' },
                        occupied: { bg: 'bg-amber-100', text: 'text-amber-800', label: 'Có khách' },
                        reserved: { bg: 'bg-blue-100', text: 'text-blue-800', label: 'Đã đặt' }
                      };
                      const config = statusConfig[table.status] || { bg: 'bg-gray-100', text: 'text-gray-800', label: table.status };
                      const isSelected = selectedTable?.id === table.id;
                      
                      return (
                        <button
                          key={table.id}
                          onClick={() => setSelectedTable(table)}
                          disabled={table.status === 'occupied'}
                          className={`p-3 rounded-lg border-2 transition-all ${
                            isSelected
                              ? 'border-amber-500 bg-amber-50'
                              : table.status === 'occupied'
                              ? 'border-gray-200 bg-gray-50 opacity-50 cursor-not-allowed'
                              : 'border-gray-200 hover:border-amber-300 hover:bg-amber-50'
                          }`}
                        >
                          <div className="text-center">
                            <div className={`text-lg font-bold ${isSelected ? 'text-amber-600' : config.text}`}>
                              {table.table_number}
                            </div>
                            <div className={`text-xs mt-1 ${config.text}`}>
                              {config.label}
                            </div>
                          </div>
                        </button>
                      );
                    })}
                  </div>
                )}
              </div>

              {/* Selected Table Info - Enhanced */}
              {selectedTable && (
                <div className="bg-gradient-to-r from-amber-50 to-orange-50 border-2 border-amber-300 rounded-xl p-4 shadow-sm">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center space-x-2 mb-2">
                        <span className="text-2xl">🪑</span>
                        <div>
                          <div className="font-bold text-lg text-gray-800">Bàn số {selectedTable.table_number}</div>
                          <div className="text-xs text-gray-500 mt-0.5">Đã chọn</div>
                        </div>
                      </div>
                      <div className="mt-3 pt-3 border-t border-amber-200">
                        <div className="flex items-center space-x-2 text-sm">
                          <span className="text-gray-500">📍</span>
                          <span className="font-medium text-gray-700">Chi nhánh:</span>
                          <span className="font-semibold text-amber-700">
                            {locations.find(l => l.id === selectedLocation)?.name || 'Chưa chọn'}
                          </span>
                        </div>
                        {locations.find(l => l.id === selectedLocation)?.address && (
                          <div className="text-xs text-gray-500 mt-1 ml-6">
                            {locations.find(l => l.id === selectedLocation)?.address}
                          </div>
                        )}
                      </div>
                    </div>
                    <div className="ml-4">
                      <div className="w-16 h-16 bg-amber-200 rounded-full flex items-center justify-center">
                        <span className="text-3xl">✓</span>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* Action Buttons */}
              <div className="flex items-center justify-end space-x-3 pt-4 border-t border-gray-200">
                <button
                  onClick={() => {
                    setShowTableModal(false);
                    setSelectedTable(null);
                  }}
                  className="px-4 py-2 text-gray-700 bg-gray-100 rounded-xl hover:bg-gray-200 transition-colors"
                >
                  Hủy
                </button>
                <button
                  onClick={createOrder}
                  disabled={!selectedTable || selectedTable.status === 'occupied'}
                  className="px-4 py-2 bg-gradient-to-r from-amber-500 to-orange-500 text-white font-semibold rounded-xl hover:from-amber-600 hover:to-orange-600 transition-all duration-200 shadow-lg disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Xác nhận đặt đơn
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      <div>
        {/* Header with Logout for Staff */}
        <div className="flex items-center justify-between mb-6">
          <div>
          <h1 className="text-2xl font-bold text-gray-800 mb-2">Thực đơn</h1>
          <p className="text-gray-600">Chọn món ăn và đồ uống cho khách hàng</p>
          </div>
          {user?.role === 'staff' && onLogout && (
            <button
              onClick={onLogout}
              className="px-4 py-2 text-sm font-medium text-gray-600 hover:text-gray-800 hover:bg-gray-100 rounded-lg transition-colors duration-200 border border-gray-300"
            >
              Đăng xuất
            </button>
          )}
        </div>

        {/* Search and Filter */}
        <div className="bg-white rounded-2xl border border-gray-200 p-6 mb-6 shadow-sm">
          <div className="grid md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Tìm kiếm món ăn</label>
              <div className="relative">
                <input
                  type="text"
                  placeholder="Nhập tên món ăn..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="w-full border border-gray-300 rounded-xl px-4 py-3 pl-10 focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                />
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <span className="text-gray-400">🔍</span>
                </div>
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Danh mục</label>
              <select
                value={selectedCategory}
                onChange={(e) => setSelectedCategory(e.target.value)}
                className="w-full border border-gray-300 rounded-xl px-4 py-3 focus:ring-2 focus:ring-amber-500 focus:border-transparent"
              >
                <option value="">Tất cả danh mục</option>
                {categories.map(cat => (
                  <option key={cat.id} value={cat.id.toString()}>{cat.name}</option>
                ))}
              </select>
            </div>
          </div>
        </div>
        
        {filteredItems.length === 0 ? (
          <div className="text-center py-12">
            <div className="text-6xl mb-4">🍽️</div>
            <h3 className="text-lg font-medium text-gray-500 mb-2">
              {items.length === 0 ? 'Chưa có món nào' : 'Không tìm thấy món ăn'}
            </h3>
            <p className="text-gray-400">
              {items.length === 0 ? 'Thực đơn sẽ được tải lên sớm' : 'Thử thay đổi từ khóa tìm kiếm hoặc danh mục'}
            </p>
          </div>
        ) : (
          <div className="grid sm:grid-cols-2 xl:grid-cols-3 gap-6">
            {filteredItems.map(item => <MenuItemCard key={item.id} item={item} onAdd={add} />)}
          </div>
        )}
      </div>
    </div>
  )
}
