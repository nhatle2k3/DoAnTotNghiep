import React from 'react';

export default function MenuItemCard({ item, onAdd }) {
  return (
    <div className="group bg-white rounded-2xl border border-gray-200 p-6 shadow-sm hover:shadow-lg hover:border-amber-300 transition-all duration-300 flex flex-col h-full">
      {/* Item Image */}
      <div className="w-full h-32 bg-gray-100 rounded-xl mb-4 overflow-hidden group-hover:scale-105 transition-transform duration-300">
        <img 
          src={item.image_url || '/images/menu/default.jpg'} 
          alt={item.name}
          className="w-full h-full object-cover"
          onError={(e) => {
            e.target.src = '/images/menu/default.jpg';
          }}
        />
      </div>
      
      {/* Item Info */}
      <div className="flex-1">
        <h3 className="text-lg font-semibold text-gray-800 mb-2 group-hover:text-amber-600 transition-colors duration-200">
          {item.name}
        </h3>
        <p className="text-sm text-gray-500 mb-4 line-clamp-2">
          Món ăn ngon và hấp dẫn
        </p>
        <div className="flex items-center justify-between mb-4">
          <span className="text-2xl font-bold text-amber-600">
            {(item.price/1000).toFixed(0)}k
          </span>
          <span className="text-sm text-gray-400">VNĐ</span>
        </div>
      </div>
      
      {/* Add Button */}
      <button 
        className="w-full px-4 py-3 bg-gradient-to-r from-amber-500 to-orange-500 text-white font-semibold rounded-xl hover:from-amber-600 hover:to-orange-600 transform hover:scale-105 transition-all duration-200 shadow-md group-hover:shadow-lg"
        onClick={() => onAdd(item)}
      >
        <span className="flex items-center justify-center space-x-2">
          <span>+</span>
          <span>Thêm vào giỏ</span>
        </span>
      </button>
    </div>
  )
}
