import React, { useEffect, useState } from 'react';
import { api } from '../api';

export default function Reports({ token }) {
  const [sales, setSales] = useState([]);
  const [tops, setTops] = useState([]);
  const [totalRevenue, setTotalRevenue] = useState(0);
  const [revenueDays, setRevenueDays] = useState(0);
  const [last30Days, setLast30Days] = useState([]);
  const [lastMonthSummary, setLastMonthSummary] = useState(null);
  const [summaryLoading, setSummaryLoading] = useState(false);

  const load = async ()=>{
    try {
      setSummaryLoading(true);
      const s = await api('/reports/sales-by-day', { token });
      setSales(s);
      const t = await api('/reports/top-items', { token });
      setTops(t);
      const tr = await api('/reports/total-revenue', { token });
      setTotalRevenue(tr.total_revenue);
      const rd = await api('/reports/revenue-days', { token });
      setRevenueDays(rd.revenue_days);
      const l30 = await api('/reports/revenue-last-30-days', { token });
      setLast30Days(l30);
      const lm = await api('/reports/last-month-summary', { token });
      setLastMonthSummary(lm);
    } catch (e) {
      // Likely not admin
    } finally {
      setSummaryLoading(false);
    }
  };
  useEffect(()=>{ load(); }, []);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-800 mb-2">Báo cáo & Thống kê</h1>
        <p className="text-gray-600">Theo dõi doanh thu và hiệu suất kinh doanh</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-gradient-to-br from-emerald-500 to-emerald-600 rounded-2xl p-6 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-emerald-100 text-sm font-medium">Tổng doanh thu</p>
              <p className="text-2xl font-bold">
                {totalRevenue > 0 
                  ? (totalRevenue / 1000 > 1000 
                      ? `${(totalRevenue / 1000000).toFixed(1)}M`
                      : `${(totalRevenue / 1000).toFixed(0)}k`)
                  : '0k'
                } VNĐ
              </p>
            </div>
            <div className="text-4xl opacity-80">💰</div>
          </div>
        </div>

        <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-2xl p-6 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-blue-100 text-sm font-medium">Số ngày có doanh thu</p>
              <p className="text-2xl font-bold">{revenueDays || 0} ngày</p>
            </div>
            <div className="text-4xl opacity-80">📅</div>
          </div>
        </div>

        <div className="bg-gradient-to-br from-purple-500 to-purple-600 rounded-2xl p-6 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-purple-100 text-sm font-medium">Doanh thu 30 ngày</p>
              <p className="text-2xl font-bold">
                {(() => {
                  const total30Days = last30Days.reduce((sum, day) => sum + Number(day.revenue), 0);
                  return total30Days > 0 
                    ? (total30Days / 1000 > 1000 
                        ? `${(total30Days / 1000000).toFixed(1)}M`
                        : `${(total30Days / 1000).toFixed(0)}k`)
                    : '0k';
                })()} VNĐ
              </p>
            </div>
            <div className="text-4xl opacity-80">📊</div>
          </div>
        </div>

        <div className="bg-gradient-to-br from-amber-500 to-amber-600 rounded-2xl p-6 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-amber-100 text-sm font-medium">Món bán chạy nhất</p>
              <p className="text-lg font-bold">{tops[0]?.name || 'Chưa có'}</p>
              <p className="text-amber-100 text-sm">{tops[0]?.qty || 0} đơn</p>
            </div>
            <div className="text-4xl opacity-80">🏆</div>
          </div>
        </div>
      </div>

      {/* Last month invoices summary (moved from CategoryManagement) */}
      <div className="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-lg font-semibold text-gray-800">Tổng hóa đơn tháng vừa rồi</h2>
            <p className="text-gray-500 text-sm">
              Thống kê dựa trên các thanh toán đã hoàn tất
            </p>
          </div>
        </div>
        <div className="mt-4">
          {summaryLoading ? (
            <p className="text-gray-500 text-sm">Đang tải dữ liệu...</p>
          ) : lastMonthSummary ? (
            <div className="grid sm:grid-cols-2 gap-4">
              <div className="bg-blue-50 rounded-xl p-4">
                <p className="text-xs text-gray-500 uppercase tracking-wide">Số hóa đơn</p>
                <p className="mt-2 text-2xl font-bold text-blue-600">
                  {lastMonthSummary.invoice_count}
                </p>
              </div>
              <div className="bg-emerald-50 rounded-xl p-4">
                <p className="text-xs text-gray-500 uppercase tracking-wide">Tổng doanh thu</p>
                <p className="mt-2 text-2xl font-bold text-emerald-600">
                  {(lastMonthSummary.total_amount / 1000).toFixed(0)}k VNĐ
                </p>
              </div>
            </div>
          ) : (
            <p className="text-gray-500 text-sm">
              Chưa có dữ liệu cho tháng vừa rồi.
            </p>
          )}
        </div>
      </div>

      {/* Charts Section */}
      <div className="grid lg:grid-cols-2 gap-6">
        {/* Revenue Chart */}
        <div className="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-lg font-semibold text-gray-800">Doanh thu 30 ngày gần nhất</h2>
            <div className="text-2xl">📈</div>
          </div>
          
          {last30Days.length === 0 ? (
            <div className="text-center py-8">
              <div className="text-4xl mb-3">📊</div>
              <p className="text-gray-500">Chưa có dữ liệu doanh thu</p>
            </div>
          ) : (
            <div className="space-y-3 max-h-96 overflow-y-auto">
              {last30Days.slice(0, 10).map((day, i) => (
                <div key={i} className="flex items-center justify-between p-3 bg-gray-50 rounded-xl">
                  <div className="flex items-center space-x-3">
                    <div className={`w-8 h-8 rounded-lg flex items-center justify-center text-sm font-bold ${
                      Number(day.revenue) > 0 
                        ? 'bg-emerald-100 text-emerald-600' 
                        : 'bg-gray-100 text-gray-500'
                    }`}>
                      {i + 1}
                    </div>
                    <div>
                      <p className="font-medium text-gray-800">{new Date(day.day).toLocaleDateString('vi-VN')}</p>
                      <p className="text-sm text-gray-500">Ngày trong tháng</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className={`font-bold ${
                      Number(day.revenue) > 0 
                        ? 'text-emerald-600' 
                        : 'text-gray-500'
                    }`}>
                      {Number(day.revenue) > 0 
                        ? `${(Number(day.revenue)/1000).toFixed(0)}k VNĐ`
                        : '0k VNĐ'
                      }
                    </p>
                    <p className="text-xs text-gray-500">Doanh thu</p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Top Items Chart */}
        <div className="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-lg font-semibold text-gray-800">Top món bán chạy</h2>
            <div className="text-2xl">🍽️</div>
          </div>
          
          {tops.length === 0 ? (
            <div className="text-center py-8">
              <div className="text-4xl mb-3">📊</div>
              <p className="text-gray-500">Chưa có dữ liệu món ăn</p>
            </div>
          ) : (
            <div className="space-y-4">
              {tops.slice(0, 5).map((item, i) => (
                <div key={i} className="flex items-center justify-between p-4 bg-gradient-to-r from-amber-50 to-orange-50 rounded-xl border border-amber-200">
                  <div className="flex items-center space-x-4">
                    <div className={`w-8 h-8 rounded-full flex items-center justify-center text-white font-bold text-sm ${
                      i === 0 ? 'bg-yellow-500' : 
                      i === 1 ? 'bg-gray-400' : 
                      i === 2 ? 'bg-amber-600' : 'bg-gray-300'
                    }`}>
                      {i + 1}
                    </div>
                    <div>
                      <p className="font-semibold text-gray-800">{item.name}</p>
                      <p className="text-sm text-gray-600">Món ăn</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-xl font-bold text-amber-600">{item.qty || 0}</p>
                    <p className="text-xs text-gray-500">đơn đã bán</p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
