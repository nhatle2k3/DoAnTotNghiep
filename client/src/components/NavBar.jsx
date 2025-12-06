import React from 'react';

export default function NavBar({ user, current, setCurrent, onLogout }) {
  const tabs = [
    { name: 'Orders', icon: '📋', label: 'Đơn hàng' },
    { name: 'Tables', icon: '🪑', label: 'Bàn' },
    { name: 'Menu', icon: '🍽️', label: 'Thực đơn' },
    { name: 'MenuManagement', icon: '⚙️', label: 'Quản lý Menu', adminOnly: true },
    { name: 'CategoryManagement', icon: '📂', label: 'Danh mục', adminOnly: true },
    { name: 'Reports', icon: '📊', label: 'Báo cáo' }
  ];
  
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
            <div className="w-8 h-8 bg-gradient-to-br from-gray-400 to-gray-600 rounded-full flex items-center justify-center text-white text-sm font-medium">
              {user?.name?.charAt(0)?.toUpperCase()}
            </div>
            <button 
              onClick={onLogout} 
              className="hidden sm:inline-block px-4 py-2 text-sm font-medium text-gray-600 hover:text-gray-800 hover:bg-gray-100 rounded-lg transition-colors duration-200"
            >
              Đăng xuất
            </button>
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
