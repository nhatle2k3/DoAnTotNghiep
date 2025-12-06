import React, { useEffect, useState } from 'react';
import { api } from '../api';

export default function CategoryManagement({ user, token }) {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(false);
  const [showForm, setShowForm] = useState(false);
  const [editingCategory, setEditingCategory] = useState(null);
  const [formData, setFormData] = useState({
    name: ''
  });

  // Check if user is admin
  const isAdmin = user?.role === 'admin';

  useEffect(() => {
    if (isAdmin) {
      loadCategories();
    }
  }, [isAdmin]);

  const loadCategories = async () => {
    setLoading(true);
    try {
      const data = await api('/menu/categories');
      setCategories(data);
    } catch (error) {
      console.error('Error loading categories:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!isAdmin) return;

    try {
      if (editingCategory) {
        await api(`/menu/categories/${editingCategory.id}`, {
          method: 'PUT',
          body: formData,
          token
        });
      } else {
        await api('/menu/categories', {
          method: 'POST',
          body: formData,
          token
        });
      }

      loadCategories();
      resetForm();
    } catch (error) {
      console.error('Error saving category:', error);
      alert('Có lỗi xảy ra khi lưu danh mục');
    }
  };

  const handleEdit = (category) => {
    setEditingCategory(category);
    setFormData({
      name: category.name
    });
    setShowForm(true);
  };

  const handleDelete = async (categoryId) => {
    if (!isAdmin || !confirm('Bạn có chắc muốn xóa danh mục này?')) return;

    try {
      await api(`/menu/categories/${categoryId}`, { method: 'DELETE', token });
      loadCategories();
    } catch (error) {
      console.error('Error deleting category:', error);
      if (error.message.includes('existing items')) {
        alert('Không thể xóa danh mục có món ăn. Vui lòng di chuyển hoặc xóa các món ăn trước.');
      } else {
        alert('Có lỗi xảy ra khi xóa danh mục');
      }
    }
  };

  const resetForm = () => {
    setFormData({
      name: ''
    });
    setEditingCategory(null);
    setShowForm(false);
  };

  if (!isAdmin) {
    return (
      <div className="text-center py-12">
        <div className="text-6xl mb-4">🔒</div>
        <h3 className="text-lg font-medium text-gray-500 mb-2">Không có quyền truy cập</h3>
        <p className="text-gray-400">Chỉ quản trị viên mới có thể quản lý danh mục</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Quản lý danh mục</h1>
          <p className="text-gray-600">Thêm, sửa, xóa danh mục sản phẩm</p>
        </div>
        <button
          onClick={() => setShowForm(true)}
          className="px-4 py-2 bg-blue-500 text-white rounded-xl hover:bg-blue-600 transition-colors duration-200 flex items-center space-x-2"
        >
          <span>➕</span>
          <span>Thêm danh mục</span>
        </button>
      </div>

      {/* Categories List */}
      {loading ? (
        <div className="text-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <p className="text-gray-600">Đang tải dữ liệu...</p>
        </div>
      ) : (
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {categories.map(category => (
            <div key={category.id} className="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm hover:shadow-md transition-all duration-200">
              {/* Category Icon */}
              <div className="w-full h-20 bg-gradient-to-br from-blue-100 to-indigo-100 rounded-xl mb-4 flex items-center justify-center">
                <span className="text-3xl">📂</span>
              </div>

              {/* Category Info */}
              <div className="mb-4">
                <h3 className="font-semibold text-gray-800 mb-2 text-center">{category.name}</h3>
                <div className="text-center">
                  <span className="text-sm text-gray-500">ID: {category.id}</span>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex space-x-2">
                <button
                  onClick={() => handleEdit(category)}
                  className="flex-1 px-3 py-2 bg-blue-500 text-white text-sm font-medium rounded-lg hover:bg-blue-600 transition-colors duration-200"
                >
                  ✏️ Sửa
                </button>
                <button
                  onClick={() => handleDelete(category.id)}
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
            <div className="bg-gradient-to-r from-blue-500 to-indigo-500 p-6 text-white rounded-t-2xl">
              <h2 className="text-xl font-bold">
                {editingCategory ? 'Sửa danh mục' : 'Thêm danh mục mới'}
              </h2>
            </div>

            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Tên danh mục</label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({...formData, name: e.target.value})}
                  className="w-full border border-gray-300 rounded-xl px-4 py-3 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="Nhập tên danh mục..."
                  required
                />
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
                  className="flex-1 px-4 py-2 bg-blue-500 text-white font-semibold rounded-xl hover:bg-blue-600 transition-colors duration-200"
                >
                  {editingCategory ? 'Cập nhật' : 'Thêm danh mục'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
