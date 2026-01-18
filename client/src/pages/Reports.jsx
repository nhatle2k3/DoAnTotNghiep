import React, { useEffect, useState } from 'react';
import { api } from '../api';

export default function Reports({ token }) {
  const [sales, setSales] = useState([]);
  const [tops, setTops] = useState([]);
  const [totalRevenue, setTotalRevenue] = useState(0);
  const [revenueDays, setRevenueDays] = useState(0);
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
    <div className="space-y-6 animate-fadeIn">
      {/* Header */}
      <div className="bg-gradient-to-r from-amber-50 to-orange-50 rounded-2xl p-6 border border-amber-200 shadow-sm">
        <div className="flex items-center space-x-4">
          <div className="w-16 h-16 bg-gradient-to-br from-amber-400 to-orange-500 rounded-xl flex items-center justify-center shadow-lg">
            <span className="text-3xl">📊</span>
          </div>
      <div>
            <h1 className="text-3xl font-bold text-gray-800 mb-1">Báo cáo & Thống kê</h1>
        <p className="text-gray-600">Theo dõi doanh thu và hiệu suất kinh doanh</p>
          </div>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-gradient-to-br from-emerald-500 to-emerald-600 rounded-2xl p-6 text-white shadow-lg hover:shadow-xl transform hover:scale-[1.02] transition-all duration-200">
          <div className="flex items-center justify-between">
            <div className="flex-1">
              <p className="text-emerald-100 text-sm font-medium mb-2">Tổng doanh thu</p>
              <p className="text-3xl font-bold">
                {totalRevenue > 0 
                  ? (totalRevenue / 1000 > 1000 
                      ? `${(totalRevenue / 1000000).toFixed(1)}M`
                      : `${(totalRevenue / 1000).toFixed(0)}k`)
                  : '0k'
                } VNĐ
              </p>
            </div>
            <div className="text-5xl opacity-90 ml-4">💰</div>
          </div>
        </div>

        <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-2xl p-6 text-white shadow-lg hover:shadow-xl transform hover:scale-[1.02] transition-all duration-200">
          <div className="flex items-center justify-between">
            <div className="flex-1">
              <p className="text-blue-100 text-sm font-medium mb-2">Số ngày có doanh thu</p>
              <p className="text-3xl font-bold">{revenueDays || 0} ngày</p>
            </div>
            <div className="text-5xl opacity-90 ml-4">📅</div>
          </div>
        </div>

        <div className="bg-gradient-to-br from-amber-500 to-amber-600 rounded-2xl p-6 text-white shadow-lg hover:shadow-xl transform hover:scale-[1.02] transition-all duration-200">
          <div className="flex items-center justify-between">
            <div className="flex-1">
              <p className="text-amber-100 text-sm font-medium mb-2">Món bán chạy nhất</p>
              <p className="text-xl font-bold truncate">{tops[0]?.name || 'Chưa có'}</p>
              <p className="text-amber-100 text-sm mt-1">{tops[0]?.qty || 0} đơn</p>
            </div>
            <div className="text-5xl opacity-90 ml-4">🏆</div>
          </div>
        </div>
      </div>

      {/* Last month invoices summary */}
      <div className="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm hover:shadow-md transition-shadow duration-200">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center space-x-3">
            <div className="w-12 h-12 bg-gradient-to-br from-emerald-400 to-emerald-600 rounded-xl flex items-center justify-center">
              <span className="text-2xl">📈</span>
            </div>
          <div>
              <h2 className="text-xl font-semibold text-gray-800">Tổng hóa đơn tháng vừa rồi</h2>
            <p className="text-gray-500 text-sm">
              Thống kê dựa trên các thanh toán đã hoàn tất
            </p>
            </div>
          </div>
        </div>
        <div className="mt-4">
          {summaryLoading ? (
            <div className="flex items-center space-x-3 text-gray-500">
              <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-emerald-500"></div>
              <p className="text-sm">Đang tải dữ liệu...</p>
            </div>
          ) : lastMonthSummary ? (
            <div className="max-w-md">
              <div className="bg-gradient-to-br from-emerald-50 via-emerald-100 to-emerald-50 rounded-xl p-6 border-2 border-emerald-200 shadow-md hover:shadow-lg transition-all duration-200 relative overflow-hidden">
                {/* Decorative background */}
                <div className="absolute top-0 right-0 w-32 h-32 bg-emerald-200 rounded-full blur-3xl opacity-30"></div>
                <div className="relative z-10">
                  <div className="flex items-center space-x-3 mb-3">
                    <div className="w-10 h-10 bg-emerald-500 rounded-lg flex items-center justify-center">
                      <span className="text-xl">💵</span>
                    </div>
                    <p className="text-xs text-gray-500 uppercase tracking-wide font-semibold">Tổng doanh thu</p>
              </div>
                  <p className="text-4xl font-bold text-emerald-600">
                  {(lastMonthSummary.total_amount / 1000).toFixed(0)}k VNĐ
                </p>
                </div>
              </div>
            </div>
          ) : (
            <div className="bg-gray-50 rounded-xl p-6 border border-gray-200 text-center">
              <div className="text-4xl mb-2">📭</div>
            <p className="text-gray-500 text-sm">
              Chưa có dữ liệu cho tháng vừa rồi.
            </p>
            </div>
          )}
        </div>
      </div>

      {/* Charts Section */}
      <div className="grid lg:grid-cols-1 gap-6">
        {/* Top Items Chart */}
        <div className="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm hover:shadow-md transition-shadow duration-200">
          <div className="flex items-center justify-between mb-6 pb-4 border-b border-gray-200">
                  <div className="flex items-center space-x-3">
              <div className="w-12 h-12 bg-gradient-to-br from-amber-400 to-orange-500 rounded-xl flex items-center justify-center">
                <span className="text-2xl">🍽️</span>
                    </div>
                    <div>
                <h2 className="text-xl font-semibold text-gray-800">Top món bán chạy</h2>
                <p className="text-gray-500 text-xs">Top 5 món được đặt nhiều nhất</p>
                </div>
            </div>
          </div>
          
          {tops.length === 0 ? (
            <div className="text-center py-12">
              <div className="text-5xl mb-4">📊</div>
              <p className="text-gray-500 font-medium">Chưa có dữ liệu món ăn</p>
              <p className="text-gray-400 text-sm mt-1">Dữ liệu sẽ hiển thị sau khi có đơn hàng</p>
            </div>
          ) : (
            <div className="space-y-3">
              {tops.slice(0, 5).map((item, i) => (
                <div 
                  key={i} 
                  className="flex items-center justify-between p-5 bg-gradient-to-r from-amber-50 via-orange-50 to-amber-50 rounded-xl border-2 border-amber-200 hover:border-amber-300 hover:shadow-md transition-all duration-200 group"
                >
                  <div className="flex items-center space-x-4 flex-1 min-w-0">
                    <div className={`w-12 h-12 rounded-xl flex items-center justify-center text-white font-bold text-lg shadow-md transform group-hover:scale-110 transition-transform duration-200 ${
                      i === 0 ? 'bg-gradient-to-br from-yellow-400 to-yellow-600' : 
                      i === 1 ? 'bg-gradient-to-br from-gray-400 to-gray-600' : 
                      i === 2 ? 'bg-gradient-to-br from-amber-500 to-amber-700' : 
                      'bg-gradient-to-br from-gray-300 to-gray-500'
                    }`}>
                      {i === 0 ? '🥇' : i === 1 ? '🥈' : i === 2 ? '🥉' : i + 1}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-bold text-gray-800 text-lg truncate">{item.name}</p>
                      <p className="text-sm text-gray-600">Món ăn</p>
                    </div>
                  </div>
                  <div className="text-right ml-4">
                    <div className="flex items-baseline space-x-1">
                      <p className="text-2xl font-bold text-amber-600">{item.qty || 0}</p>
                      <span className="text-xs text-gray-500">đơn</span>
                    </div>
                    <p className="text-xs text-gray-500 mt-1">đã bán</p>
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
