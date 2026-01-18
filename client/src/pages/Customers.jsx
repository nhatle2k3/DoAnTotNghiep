import React, { useEffect, useState } from 'react';
import { api } from '../api';

export default function Customers({ token }) {
  const [customers, setCustomers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      try {
        setLoading(true);
        setError(null);
        const data = await api('/users?role=customer', { token });
        if (!cancelled) setCustomers(data);
      } catch (e) {
        if (!cancelled) setError(e.message || 'Không thể tải danh sách khách hàng');
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    load();
    return () => {
      cancelled = true;
    };
  }, [token]);

  return (
    <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 sm:p-6">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h2 className="text-lg font-semibold text-gray-800">Khách hàng</h2>
          <p className="text-sm text-gray-500">
            Danh sách khách hàng lấy từ hệ thống (role = customer).
          </p>
        </div>
      </div>

      {loading && <div className="text-sm text-gray-500">Đang tải...</div>}
      {error && !loading && (
        <div className="text-sm text-red-500 mb-3">Lỗi: {error}</div>
      )}

      {!loading && !error && (
        <div className="overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="border-b bg-gray-50">
                <th className="text-left px-3 py-2 text-gray-500 font-medium">Tên</th>
                <th className="text-left px-3 py-2 text-gray-500 font-medium">Email</th>
                <th className="text-left px-3 py-2 text-gray-500 font-medium">Ngày tạo</th>
              </tr>
            </thead>
            <tbody>
              {customers.length === 0 && (
                <tr>
                  <td
                    colSpan={3}
                    className="px-3 py-3 text-center text-gray-400 italic"
                  >
                    Chưa có khách hàng nào.
                  </td>
                </tr>
              )}
              {customers.map((c) => (
                <tr key={c.id} className="border-b last:border-0">
                  <td className="px-3 py-2 text-gray-800">{c.full_name}</td>
                  <td className="px-3 py-2 text-gray-600">{c.email}</td>
                  <td className="px-3 py-2 text-gray-500 text-xs">
                    {c.created_at
                      ? new Date(c.created_at).toLocaleString('vi-VN')
                      : '-'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}



