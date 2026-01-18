/**
 * Component thanh điều hướng chính của ứng dụng
 * - Hiển thị logo và thông tin người dùng
 * - Cung cấp menu điều hướng giữa các trang
 * - Dropdown menu với chức năng đăng xuất
 * - Responsive: hiển thị bottom bar trên mobile
 */
import React, { useState, useEffect, useRef } from 'react';

export default function NavBar({ user, current, setCurrent, onLogout }) {
  // State quản lý dropdown menu
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const dropdownRef = useRef(null); // Ref để detect click outside
  
  // Danh sách các tab điều hướng
  const tabs = [
    { name: 'Orders', icon: '📋', label: 'Đơn hàng' },
    { name: 'Tables', icon: '🪑', label: 'Bàn' },
    { name: 'Menu', icon: '🍽️', label: 'Thực đơn' },
    { name: 'MenuManagement', icon: '⚙️', label: 'Quản lý Menu', adminOnly: true },
    { name: 'CategoryManagement', icon: '📂', label: 'Danh mục', adminOnly: true },
    { name: 'Customers', icon: '👥', label: 'Khách hàng', adminOnly: true },
    { name: 'Staff', icon: '🧑‍🍳', label: 'Nhân viên', adminOnly: true },
    { name: 'Reports', icon: '📊', label: 'Báo cáo' }
  ];

  /**
   * Effect: Đóng dropdown khi click bên ngoài
   * Thêm event listener khi dropdown mở, remove khi đóng hoặc unmount
   */
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setDropdownOpen(false);
      }
    };

    if (dropdownOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [dropdownOpen]);

  /**
   * Xử lý đăng xuất: đóng dropdown và gọi callback onLogout
   */
  const handleLogout = () => {
    setDropdownOpen(false);
    onLogout();
  };
  
  return (
    <div className="w-full bg-white/95 backdrop-blur-sm border-b border-gray-200 sticky top-0 z-50 shadow-sm">
      <div className="max-w-7xl mx-auto">
        {/* Top Header */}
        <div className="flex items-center justify-between px-6 py-4">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-gradient-to-br from-amber-400 to-orange-500 rounded-xl flex items-center justify-center shadow-lg">
              <span className="text-xl">☕</span>
            </div>
            <div>
              <h1 className="text-xl font-bold text-gray-800">Trình Café</h1>
              <p className="text-xs text-gray-500">Hệ thống quản lý</p>
            </div>
          </div>
          
          <div className="flex items-center space-x-4">
            <div className="text-right hidden sm:block">
              <div className="text-sm font-medium text-gray-800">{user?.name}</div>
              <div className="text-xs text-gray-500 capitalize">{user?.role}</div>
            </div>
            
            {/* Avatar with Dropdown */}
            <div className="relative" ref={dropdownRef}>
              <button
                onClick={() => setDropdownOpen(!dropdownOpen)}
                className="flex items-center space-x-2 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:ring-offset-2 rounded-full transition-all duration-200"
                aria-label="Menu người dùng"
              >
                <div className={`w-10 h-10 bg-gradient-to-br from-amber-400 to-orange-500 rounded-full flex items-center justify-center text-white text-sm font-bold shadow-md hover:shadow-lg transition-all duration-200 ${
                  dropdownOpen ? 'ring-2 ring-amber-500 ring-offset-2' : ''
                }`}>
                  {user?.name?.charAt(0)?.toUpperCase()}
                </div>
                <svg 
                  className={`w-4 h-4 text-gray-600 transition-transform duration-200 ${dropdownOpen ? 'rotate-180' : ''}`}
                  fill="none" 
                  stroke="currentColor" 
                  viewBox="0 0 24 24"
                >
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
              </button>

              {/* Dropdown Menu */}
              {dropdownOpen && (
                <>
                  {/* Backdrop overlay for mobile */}
                  <div 
                    className="fixed inset-0 bg-black/20 z-40 sm:hidden"
                    onClick={() => setDropdownOpen(false)}
                  />
                  
                  {/* Dropdown Content */}
                  <div className="absolute right-0 mt-2 w-56 bg-white rounded-xl shadow-2xl border border-gray-200 overflow-hidden z-50 animate-fadeIn">
                    {/* User Info */}
                    <div className="px-4 py-3 bg-gradient-to-r from-amber-50 to-orange-50 border-b border-gray-200">
                      <div className="flex items-center space-x-3">
                        <div className="w-10 h-10 bg-gradient-to-br from-amber-400 to-orange-500 rounded-full flex items-center justify-center text-white text-sm font-bold shadow-sm">
              {user?.name?.charAt(0)?.toUpperCase()}
            </div>
                        <div className="flex-1 min-w-0">
                          <div className="text-sm font-semibold text-gray-800 truncate">{user?.name}</div>
                          <div className="text-xs text-gray-500 capitalize">{user?.role}</div>
                        </div>
                      </div>
                      {user?.email && (
                        <div className="text-xs text-gray-400 mt-2 truncate">{user?.email}</div>
                      )}
                    </div>

                    {/* Menu Items */}
                    <div className="py-2">
            <button 
                        onClick={handleLogout}
                        className="w-full px-4 py-3 text-left flex items-center space-x-3 text-gray-700 hover:bg-red-50 hover:text-red-600 transition-all duration-200 group"
                      >
                        <span className="text-lg group-hover:scale-110 transition-transform duration-200">🚪</span>
                        <span className="font-medium">Đăng xuất</span>
                        <svg className="ml-auto w-4 h-4 text-gray-400 group-hover:text-red-600 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                        </svg>
            </button>
                    </div>
                  </div>
                </>
              )}
            </div>
          </div>
        </div>
        
        {/* Navigation Tabs */}
        <div className="px-4 sm:px-6 pb-4">
          <div className="flex space-x-1 bg-gray-100 p-1 rounded-xl overflow-x-auto">
            {tabs.filter(tab => !tab.adminOnly || user?.role === 'admin').map(tab => (
              <button
                key={tab.name}
                onClick={() => setCurrent(tab.name)}
                className={`flex-shrink-0 flex items-center justify-center space-x-1 sm:space-x-2 px-2 sm:px-4 py-3 rounded-lg font-medium transition-all duration-200 ${
                  current === tab.name
                    ? 'bg-white text-amber-600 shadow-sm'
                    : 'text-gray-600 hover:text-gray-800 hover:bg-white/50'
                }`}
              >
                <span className="text-lg">{tab.icon}</span>
                <span className="text-xs sm:text-sm hidden sm:block">{tab.label}</span>
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Bottom Tab Bar for mobile */}
      <div className="fixed bottom-0 inset-x-0 sm:hidden z-50">
        <div className="safe-bottom bg-white/95 backdrop-blur-sm border-t border-gray-200 shadow-lg">
          <div className="max-w-7xl mx-auto px-2 py-2">
            <div className="grid grid-cols-4 gap-1">
              {tabs
                .filter(tab => !tab.adminOnly || user?.role === 'admin')
                .slice(0, 4)
                .map(tab => (
                  <button
                    key={tab.name}
                    onClick={() => setCurrent(tab.name)}
                    className={`flex flex-col items-center justify-center py-2 rounded-lg text-xs font-medium transition-colors ${
                      current === tab.name ? 'text-amber-600 bg-amber-50' : 'text-gray-600 hover:text-gray-800'
                    }`}
                  >
                    <span className="text-base mb-1">{tab.icon}</span>
                    <span className="truncate">{tab.label}</span>
                  </button>
                ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
