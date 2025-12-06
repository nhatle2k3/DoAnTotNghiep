import React, { useEffect, useState } from 'react';
import { api } from '../api';
import MenuItemCard from '../components/MenuItemCard';

export default function Menu({ token, user }) {
  const [items, setItems] = useState([]);
  const [cart, setCart] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('');
  const [categories, setCategories] = useState([]);

  const load = async ()=>{
    const data = await api('/menu');
    setItems(data);
  };

  const loadCategories = async () => {
    const data = await api('/menu/categories');
    setCategories(data);
  };

  useEffect(()=>{ 
    load(); 
    loadCategories();
  }, []);

  const add = (item)=>{
    setCart(c => {
      const found = c.find(x=>x.item_id===item.id);
      if (found) return c.map(x=> x.item_id===item.id ? {...x, quantity: x.quantity+1} : x);
      return [...c, { item_id: item.id, name: item.name, price: item.price, quantity: 1 }];
    });
  };

  const total = cart.reduce((s,x)=>s + x.price*x.quantity, 0);

  // Filter items based on search and category
  const filteredItems = items.filter(item => {
    const matchesSearch = item.name.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = !selectedCategory || item.category_id.toString() === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  const createOrder = async () => {
    const table_id = prompt('Nhập ID bàn (ví dụ 1):');
    if (!table_id) return;
    try {
      const res = await api('/orders', { method:'POST', body:{ table_id: Number(table_id), items: cart.map(({item_id, quantity})=>({item_id, quantity})) } });
      alert('Tạo đơn thành công. Tổng: ' + res.total);
      setCart([]);
    } catch (e) {
      alert('Lỗi: ' + e.message);
    }
  };

  return (
    <div className="grid lg:grid-cols-4 gap-8">
      {/* Menu Section */}
      <div className="lg:col-span-3">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-800 mb-2">Thực đơn</h1>
          <p className="text-gray-600">Chọn món ăn và đồ uống cho khách hàng</p>
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
      
      {/* Cart Section */}
      <div className="lg:col-span-1">
        <div className="sticky top-24">
          <div className="bg-white rounded-2xl border border-gray-200 shadow-sm">
            {/* Cart Header */}
            <div className="p-6 border-b border-gray-100">
              <h2 className="text-lg font-semibold text-gray-800 flex items-center">
                <span className="mr-2">🛒</span>
                Giỏ hàng
                {cart.length > 0 && (
                  <span className="ml-2 px-2 py-1 bg-amber-100 text-amber-800 text-xs font-medium rounded-full">
                    {cart.length}
                  </span>
                )}
              </h2>
            </div>
            
            {/* Cart Items */}
            <div className="p-6">
              {cart.length === 0 ? (
                <div className="text-center py-8">
                  <div className="text-4xl mb-3">🛒</div>
                  <p className="text-gray-500 text-sm">Chưa có món nào</p>
                  <p className="text-gray-400 text-xs mt-1">Thêm món từ thực đơn</p>
                </div>
              ) : (
                <div className="space-y-4">
                  {cart.map((item, index) => (
                    <div key={index} className="flex items-center justify-between p-3 bg-gray-50 rounded-xl">
                      <div className="flex-1">
                        <div className="font-medium text-gray-800 text-sm">{item.name}</div>
                        <div className="text-gray-500 text-xs">{(item.price/1000).toFixed(0)}k VNĐ</div>
                      </div>
                      <div className="flex items-center space-x-2">
                        <span className="text-sm font-medium text-gray-600">x{item.quantity}</span>
                        <div className="w-6 h-6 bg-amber-500 text-white rounded-full flex items-center justify-center text-xs font-bold">
                          -
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
            
            {/* Cart Footer */}
            {cart.length > 0 && (
              <div className="p-6 border-t border-gray-100 space-y-4">
                <div className="flex justify-between items-center">
                  <span className="font-semibold text-gray-800">Tổng cộng:</span>
                  <span className="text-xl font-bold text-amber-600">{(total/1000).toFixed(0)}k VNĐ</span>
                </div>
                
                <button 
                  onClick={createOrder} 
                  className="w-full px-4 py-3 bg-gradient-to-r from-amber-500 to-orange-500 text-white font-semibold rounded-xl hover:from-amber-600 hover:to-orange-600 transform hover:scale-105 transition-all duration-200 shadow-lg"
                >
                  Tạo đơn hàng
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
