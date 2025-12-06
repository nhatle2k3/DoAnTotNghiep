import React, { useEffect, useState } from 'react';
import { api } from '../api';

export default function MenuManagement({ user, token }) {
  const [items, setItems] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(false);
  const [showForm, setShowForm] = useState(false);
  const [editingItem, setEditingItem] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    price: '',
    category_id: '',
    available: true,
    image_url: ''
  });

  // Check if user is admin
  const isAdmin = user?.role === 'admin';

  useEffect(() => {
    if (isAdmin) {
      loadItems();
      loadCategories();
    }
  }, [isAdmin]);

  const loadItems = async () => {
    setLoading(true);
    try {
      const data = await api('/menu');
      setItems(data);
    } catch (error) {
      console.error('Error loading items:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadCategories = async () => {
    try {
      const data = await api('/menu/categories');
      setCategories(data);
    } catch (error) {
      console.error('Error loading categories:', error);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!isAdmin) return;

    try {
      const itemData = {
        ...formData,
        price: parseFloat(formData.price) * 1000, // Convert to cents
        category_id: parseInt(formData.category_id)
      };

      if (editingItem) {
        await api(`/menu/${editingItem.id}`, {
          method: 'PUT',
          body: itemData,
          token
        });
      } else {
        await api('/menu', {
          method: 'POST',
          body: itemData,
          token
        });
      }

      loadItems();
      resetForm();
    } catch (error) {
      console.error('Error saving item:', error);
      alert('Có lỗi xảy ra khi lưu món ăn');
    }
  };

  const handleEdit = (item) => {
    setEditingItem(item);
    setFormData({
      name: item.name,
      price: (item.price / 1000).toString(),
      category_id: item.category_id.toString(),
      available: item.available,
      image_url: item.image_url || ''
    });
    setShowForm(true);
  };

  const handleDelete = async (itemId) => {
    if (!isAdmin || !confirm('Bạn có chắc muốn xóa món ăn này?')) return;

    try {
      await api(`/menu/${itemId}`, { method: 'DELETE', token });
      loadItems();
    } catch (error) {
      console.error('Error deleting item:', error);
      alert('Có lỗi xảy ra khi xóa món ăn');
    }
  };

  const resetForm = () => {
    setFormData({
      name: '',
      price: '',
      category_id: '',
      available: true,
      image_url: ''
    });
    setEditingItem(null);
    setShowForm(false);
  };

  if (!isAdmin) {
    return (
      <div className="text-center py-12">
        <div className="text-6xl mb-4">🔒</div>
        <h3 className="text-lg font-medium text-gray-500 mb-2">Không có quyền truy cập</h3>
        <p className="text-gray-400">Chỉ quản trị viên mới có thể quản lý menu</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Quản lý thực đơn</h1>
          <p className="text-gray-600">Thêm, sửa, xóa món ăn và đồ uống</p>
        </div>
        <button
          onClick={() => setShowForm(true)}
          className="px-4 py-2 bg-amber-500 text-white rounded-xl hover:bg-amber-600 transition-colors duration-200 flex items-center space-x-2"
        >
          <span>➕</span>
          <span>Thêm món mới</span>
        </button>
      </div>

      {/* Items Grid */}
      {loading ? (
        <div className="text-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-amber-500 mx-auto mb-4"></div>
          <p className="text-gray-600">Đang tải dữ liệu...</p>
        </div>
      ) : (
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {items.map(item => (
            <div key={item.id} className="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm hover:shadow-md transition-all duration-200">
              {/* Item Image */}
              <div className="w-full h-32 bg-gradient-to-br from-amber-100 to-orange-100 rounded-xl mb-4 flex items-center justify-center">
                {item.image_url ? (
                  <img src={item.image_url} alt={item.name} className="w-full h-full object-cover rounded-xl" />
                ) : (
                  <span className="text-4xl">🍽️</span>
                )}
              </div>

              {/* Item Info */}
              <div className="mb-4">
                <h3 className="font-semibold text-gray-800 mb-1">{item.name}</h3>
                <p className="text-sm text-gray-500 mb-2">{item.category_name}</p>
                <div className="flex items-center justify-between">
                  <span className="text-lg font-bold text-amber-600">
                    {(item.price/1000).toFixed(0)}k VNĐ
                  </span>
                  <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                    item.available 
                      ? 'bg-green-100 text-green-800' 
                      : 'bg-red-100 text-red-800'
                  }`}>
                    {item.available ? 'Có sẵn' : 'Hết hàng'}
                  </span>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex space-x-2">
                <button
                  onClick={() => handleEdit(item)}
                  className="flex-1 px-3 py-2 bg-blue-500 text-white text-sm font-medium rounded-lg hover:bg-blue-600 transition-colors duration-200"
                >
                  ✏️ Sửa
                </button>
                <button
                  onClick={() => handleDelete(item.id)}
                  className="px-3 py-2 bg-red-500 text-white text-sm font-medium rounded-lg hover:bg-red-600 transition-colors duration-200"
                >
                  🗑️
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Add/Edit Form Modal */}
      {showForm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl max-w-md w-full shadow-2xl">
            <div className="bg-gradient-to-r from-amber-500 to-orange-500 p-6 text-white rounded-t-2xl">
              <h2 className="text-xl font-bold">
                {editingItem ? 'Sửa món ăn' : 'Thêm món mới'}
              </h2>
            </div>

            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Tên món</label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({...formData, name: e.target.value})}
                  className="w-full border border-gray-300 rounded-xl px-4 py-3 focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Giá (k VNĐ)</label>
                <input
                  type="number"
                  step="0.1"
                  value={formData.price}
                  onChange={(e) => setFormData({...formData, price: e.target.value})}
                  className="w-full border border-gray-300 rounded-xl px-4 py-3 focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Danh mục</label>
                <select
                  value={formData.category_id}
                  onChange={(e) => setFormData({...formData, category_id: e.target.value})}
                  className="w-full border border-gray-300 rounded-xl px-4 py-3 focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                  required
                >
                  <option value="">Chọn danh mục</option>
                  {categories.map(cat => (
                    <option key={cat.id} value={cat.id}>{cat.name}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">URL ảnh (tùy chọn)</label>
                <input
                  type="url"
                  value={formData.image_url}
                  onChange={(e) => setFormData({...formData, image_url: e.target.value})}
                  className="w-full border border-gray-300 rounded-xl px-4 py-3 focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                />
              </div>

              <div className="flex items-center">
                <input
                  type="checkbox"
                  id="available"
                  checked={formData.available}
                  onChange={(e) => setFormData({...formData, available: e.target.checked})}
                  className="h-4 w-4 text-amber-600 focus:ring-amber-500 border-gray-300 rounded"
                />
                <label htmlFor="available" className="ml-2 text-sm text-gray-700">
                  Có sẵn
                </label>
              </div>

              <div className="flex space-x-3 pt-4">
                <button
                  type="button"
                  onClick={resetForm}
                  className="flex-1 px-4 py-2 text-gray-600 hover:text-gray-800 transition-colors duration-200"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="flex-1 px-4 py-2 bg-amber-500 text-white font-semibold rounded-xl hover:bg-amber-600 transition-colors duration-200"
                >
                  {editingItem ? 'Cập nhật' : 'Thêm món'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
