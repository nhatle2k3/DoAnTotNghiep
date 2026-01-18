import React, { useEffect, useState } from 'react';
import { api } from '../api';

// Danh sách chức vụ có sẵn
const POSITION_OPTIONS = [
  'Phục vụ',
  'Barista',
  'Thu ngân',
  'Quản lý',
  'Bếp trưởng',
  'Nhân viên bếp',
  'Bảo vệ',
  'Tạp vụ'
];

// Danh sách ca làm việc có sẵn
const WORK_SCHEDULE_OPTIONS = [
  'Sáng (7h-12h)',
  'Chiều (13h-18h)',
  'Tối (18h-22h)',
  'Full-time (7h-22h)',
  'Ca 1 (6h-14h)',
  'Ca 2 (14h-22h)',
  'Ca đêm (22h-6h)',
  'Linh hoạt'
];

export default function Staff({ token }) {
  const [staff, setStaff] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showModal, setShowModal] = useState(false);
  const [editingStaff, setEditingStaff] = useState(null);
  const [formData, setFormData] = useState({
    full_name: '',
    email: '',
    password: '',
    phone: '',
    position: '',
    salary: '',
    work_schedule: '',
    status: 'working',
    started_at: ''
  });
  const [formError, setFormError] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [customPosition, setCustomPosition] = useState('');
  const [customWorkSchedule, setCustomWorkSchedule] = useState('');

  const loadStaff = React.useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await api('/users?role=staff', { token });
      setStaff(data);
    } catch (e) {
      setError(e.message || 'Không thể tải danh sách nhân viên');
    } finally {
      setLoading(false);
    }
  }, [token]);

  useEffect(() => {
    loadStaff();
  }, [loadStaff]);

  const handleAddNew = () => {
    setEditingStaff(null);
    setFormData({
      full_name: '',
      email: '',
      password: '',
      phone: '',
      position: '',
      salary: '',
      work_schedule: '',
      status: 'working',
      started_at: ''
    });
    setCustomPosition('');
    setCustomWorkSchedule('');
    setFormError('');
    setShowModal(true);
  };

  const handleEdit = async (staffId) => {
    try {
      const data = await api(`/users/${staffId}`, { token });
      setEditingStaff(data);
      
      // Kiểm tra position có trong danh sách không
      const position = data.position || '';
      const isCustomPosition = position && !POSITION_OPTIONS.includes(position);
      
      // Kiểm tra work_schedule có trong danh sách không
      const workSchedule = data.work_schedule || '';
      const isCustomWorkSchedule = workSchedule && !WORK_SCHEDULE_OPTIONS.includes(workSchedule);
      
      setFormData({
        full_name: data.full_name || '',
        email: data.email || '',
        password: '', // Không hiển thị password khi sửa
        phone: data.phone || '',
        position: isCustomPosition ? 'Khác' : position,
        salary: data.salary || '',
        work_schedule: isCustomWorkSchedule ? 'Khác' : workSchedule,
        status: data.status || 'working',
        started_at: data.started_at ? data.started_at.split('T')[0] : ''
      });
      setCustomPosition(isCustomPosition ? position : '');
      setCustomWorkSchedule(isCustomWorkSchedule ? workSchedule : '');
      setFormError('');
      setShowModal(true);
    } catch (e) {
      setError(e.message || 'Không thể tải thông tin nhân viên');
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setFormError('');
    setSubmitting(true);

    try {
      // Validation
      if (!formData.full_name || !formData.email) {
        setFormError('Họ tên và email là bắt buộc');
        setSubmitting(false);
        return;
      }

      if (!editingStaff && !formData.password) {
        setFormError('Mật khẩu là bắt buộc khi tạo mới');
        setSubmitting(false);
        return;
      }

      if (formData.password && formData.password.length < 6) {
        setFormError('Mật khẩu phải có ít nhất 6 ký tự');
        setSubmitting(false);
        return;
      }

      // Xử lý position: nếu chọn "Khác" thì dùng customPosition, ngược lại dùng formData.position
      const finalPosition = formData.position === 'Khác' 
        ? (customPosition || null)
        : (formData.position || null);
      
      // Xử lý work_schedule: nếu chọn "Khác" thì dùng customWorkSchedule, ngược lại dùng formData.work_schedule
      const finalWorkSchedule = formData.work_schedule === 'Khác'
        ? (customWorkSchedule || null)
        : (formData.work_schedule || null);

      const payload = {
        full_name: formData.full_name,
        email: formData.email,
        phone: formData.phone || null,
        position: finalPosition,
        salary: formData.salary ? parseFloat(formData.salary) : null,
        work_schedule: finalWorkSchedule,
        status: formData.status || 'working',
        started_at: formData.started_at || null
      };

      if (formData.password) {
        payload.password = formData.password;
      }

      if (editingStaff) {
        // Update
        await api(`/users/staff/${editingStaff.id}`, {
          method: 'PUT',
          body: payload,
          token
        });
      } else {
        // Create
        await api('/users/staff', {
          method: 'POST',
          body: payload,
          token
        });
      }

      setShowModal(false);
      await loadStaff();
    } catch (e) {
      setFormError(e.message || 'Có lỗi xảy ra. Vui lòng thử lại.');
    } finally {
      setSubmitting(false);
    }
  };

  const getStatusBadge = (status) => {
    const statusMap = {
      working: { label: 'Đang làm việc', color: 'bg-green-100 text-green-800' },
      on_leave: { label: 'Nghỉ phép', color: 'bg-yellow-100 text-yellow-800' },
      resigned: { label: 'Đã nghỉ việc', color: 'bg-red-100 text-red-800' }
    };
    const s = statusMap[status] || statusMap.working;
    return (
      <span className={`px-2 py-1 rounded-full text-xs font-medium ${s.color}`}>
        {s.label}
      </span>
    );
  };

  const formatCurrency = (amount) => {
    if (!amount) return '-';
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND'
    }).format(amount);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-2xl p-6 border border-blue-200 shadow-sm">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="w-16 h-16 bg-gradient-to-br from-blue-400 to-indigo-500 rounded-xl flex items-center justify-center shadow-lg">
              <span className="text-3xl">👥</span>
            </div>
            <div>
              <h1 className="text-3xl font-bold text-gray-800 mb-1">Quản lý nhân viên</h1>
              <p className="text-gray-600">Thêm mới và quản lý thông tin nhân viên</p>
            </div>
          </div>
          <button
            onClick={handleAddNew}
            className="bg-gradient-to-r from-blue-500 to-indigo-600 text-white px-6 py-3 rounded-xl font-semibold shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-200 flex items-center space-x-2"
          >
            <span>➕</span>
            <span>Thêm nhân viên</span>
          </button>
        </div>
      </div>

      {/* Error message */}
      {error && !loading && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
          Lỗi: {error}
        </div>
      )}

      {/* Staff Table */}
      <div className="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden">
        {loading ? (
          <div className="p-8 text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500 mx-auto mb-3"></div>
            <p className="text-gray-500">Đang tải dữ liệu...</p>
          </div>
        ) : staff.length === 0 ? (
          <div className="p-12 text-center">
            <div className="text-5xl mb-4">👥</div>
            <p className="text-gray-500 text-lg font-medium">Chưa có nhân viên nào</p>
            <p className="text-gray-400 text-sm mt-1">Nhấn "Thêm nhân viên" để bắt đầu</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full">
              <thead className="bg-gradient-to-r from-gray-50 to-gray-100">
                <tr>
                  <th className="text-left px-6 py-4 text-gray-700 font-semibold">Họ tên</th>
                  <th className="text-left px-6 py-4 text-gray-700 font-semibold">Email</th>
                  <th className="text-left px-6 py-4 text-gray-700 font-semibold">Số điện thoại</th>
                  <th className="text-left px-6 py-4 text-gray-700 font-semibold">Chức vụ</th>
                  <th className="text-left px-6 py-4 text-gray-700 font-semibold">Lương</th>
                  <th className="text-left px-6 py-4 text-gray-700 font-semibold">Ca làm việc</th>
                  <th className="text-left px-6 py-4 text-gray-700 font-semibold">Trạng thái</th>
                  <th className="text-left px-6 py-4 text-gray-700 font-semibold">Thao tác</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {staff.map((s) => (
                  <tr key={s.id} className="hover:bg-gray-50 transition-colors">
                    <td className="px-6 py-4 text-gray-800 font-medium">{s.full_name}</td>
                    <td className="px-6 py-4 text-gray-600">{s.email}</td>
                    <td className="px-6 py-4 text-gray-600">{s.phone || '-'}</td>
                    <td className="px-6 py-4 text-gray-600">{s.position || '-'}</td>
                    <td className="px-6 py-4 text-gray-600">{formatCurrency(s.salary)}</td>
                    <td className="px-6 py-4 text-gray-600">{s.work_schedule || '-'}</td>
                    <td className="px-6 py-4">{getStatusBadge(s.status)}</td>
                    <td className="px-6 py-4">
                      <button
                        onClick={() => handleEdit(s.id)}
                        className="bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600 transition-colors text-sm font-medium"
                      >
                        ✏️ Sửa
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="sticky top-0 bg-gradient-to-r from-blue-500 to-indigo-600 text-white p-6 rounded-t-2xl">
              <div className="flex items-center justify-between">
                <h2 className="text-2xl font-bold">
                  {editingStaff ? 'Sửa thông tin nhân viên' : 'Thêm nhân viên mới'}
                </h2>
                <button
                  onClick={() => setShowModal(false)}
                  className="text-white hover:text-gray-200 text-2xl font-bold"
                >
                  ×
                </button>
              </div>
            </div>

            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              {formError && (
                <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
                  {formError}
                </div>
              )}

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Họ tên <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    value={formData.full_name}
                    onChange={(e) => setFormData({ ...formData, full_name: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Email <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="email"
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Mật khẩu {!editingStaff && <span className="text-red-500">*</span>}
                    {editingStaff && <span className="text-gray-400 text-xs">(để trống nếu không đổi)</span>}
                  </label>
                  <input
                    type="password"
                    value={formData.password}
                    onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    required={!editingStaff}
                    minLength={6}
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Số điện thoại
                  </label>
                  <input
                    type="tel"
                    value={formData.phone}
                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Chức vụ
                  </label>
                  <select
                    value={formData.position}
                    onChange={(e) => {
                      setFormData({ ...formData, position: e.target.value });
                      if (e.target.value !== 'Khác') {
                        setCustomPosition('');
                      }
                    }}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  >
                    <option value="">-- Chọn chức vụ --</option>
                    {POSITION_OPTIONS.map((pos) => (
                      <option key={pos} value={pos}>{pos}</option>
                    ))}
                    <option value="Khác">Khác</option>
                  </select>
                  {formData.position === 'Khác' && (
                    <input
                      type="text"
                      value={customPosition}
                      onChange={(e) => setCustomPosition(e.target.value)}
                      className="w-full mt-2 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      placeholder="Nhập chức vụ khác..."
                    />
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Lương (VNĐ)
                  </label>
                  <input
                    type="number"
                    value={formData.salary}
                    onChange={(e) => setFormData({ ...formData, salary: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    placeholder="VD: 5000000"
                    min="0"
                    step="1000"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Ca làm việc
                  </label>
                  <select
                    value={formData.work_schedule}
                    onChange={(e) => {
                      setFormData({ ...formData, work_schedule: e.target.value });
                      if (e.target.value !== 'Khác') {
                        setCustomWorkSchedule('');
                      }
                    }}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  >
                    <option value="">-- Chọn ca làm việc --</option>
                    {WORK_SCHEDULE_OPTIONS.map((schedule) => (
                      <option key={schedule} value={schedule}>{schedule}</option>
                    ))}
                    <option value="Khác">Khác</option>
                  </select>
                  {formData.work_schedule === 'Khác' && (
                    <input
                      type="text"
                      value={customWorkSchedule}
                      onChange={(e) => setCustomWorkSchedule(e.target.value)}
                      className="w-full mt-2 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      placeholder="Nhập ca làm việc khác..."
                    />
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Trạng thái
                  </label>
                  <select
                    value={formData.status}
                    onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  >
                    <option value="working">Đang làm việc</option>
                    <option value="on_leave">Nghỉ phép</option>
                    <option value="resigned">Đã nghỉ việc</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Ngày bắt đầu làm việc
                  </label>
                  <input
                    type="date"
                    value={formData.started_at}
                    onChange={(e) => setFormData({ ...formData, started_at: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>
              </div>

              <div className="flex justify-end space-x-3 pt-4 border-t">
                <button
                  type="button"
                  onClick={() => setShowModal(false)}
                  className="px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors font-medium"
                  disabled={submitting}
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  className="px-6 py-2 bg-gradient-to-r from-blue-500 to-indigo-600 text-white rounded-lg hover:shadow-lg transition-all font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {submitting ? 'Đang xử lý...' : editingStaff ? 'Cập nhật' : 'Tạo mới'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
