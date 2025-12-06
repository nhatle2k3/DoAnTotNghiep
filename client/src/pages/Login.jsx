import React, { useState } from 'react';
import { api } from '../api';

export default function Login({ onLogin }) {
  const [email, setEmail] = useState('admin@trinhcafe.vn');
  const [password, setPassword] = useState('admin123');
  const [error, setError] = useState(null);

  const submit = async (e) => {
    e.preventDefault();
    setError(null);
    try {
      const res = await api('/auth/login', { method:'POST', body:{ email, password } });
      onLogin(res.token);
    } catch (e) {
      setError(e.message);
    }
  }

  return (
    <div className="min-h-screen relative overflow-hidden bg-gradient-to-br from-amber-50 via-orange-50 to-red-50">
      {/* Background decoration */}
      <div className="absolute inset-0 bg-[url('data:image/svg+xml,%3Csvg%20width%3D%2260%22%20height%3D%2260%22%20viewBox%3D%220%200%2060%2060%22%20xmlns%3D%22http%3A//www.w3.org/2000/svg%22%3E%3Cg%20fill%3D%22none%22%20fill-rule%3D%22evenodd%22%3E%3Cg%20fill%3D%22%23fbbf24%22%20fill-opacity%3D%220.1%22%3E%3Ccircle%20cx%3D%2230%22%20cy%3D%2230%22%20r%3D%222%22/%3E%3C/g%3E%3C/g%3E%3C/svg%3E')] opacity-40"></div>
      
      <div className="relative min-h-screen flex items-center justify-center p-4">
        <div className="w-full max-w-md">
          {/* Logo/Brand */}
          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-br from-amber-400 to-orange-500 rounded-2xl shadow-lg mb-4">
              <span className="text-3xl">☕</span>
            </div>
            <h1 className="text-3xl font-bold text-gray-800 mb-2">Trình Café</h1>
            <p className="text-gray-600">Hệ thống quản lý quán cà phê</p>
          </div>

          {/* Login Form */}
          <form onSubmit={submit} className="bg-white/80 backdrop-blur-sm p-8 rounded-3xl shadow-2xl border border-white/20">
            <div className="text-2xl font-bold text-center mb-6 text-gray-800">Đăng nhập</div>
            
            {error && (
              <div className="mb-4 p-3 text-sm rounded-xl bg-red-50 text-red-700 border border-red-200 flex items-center">
                <span className="mr-2">⚠️</span>
                {error}
              </div>
            )}
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Email</label>
                <input 
                  className="w-full border border-gray-300 rounded-xl px-4 py-3 focus:ring-2 focus:ring-amber-500 focus:border-transparent transition-all duration-200" 
                  value={email} 
                  onChange={e=>setEmail(e.target.value)}
                  placeholder="admin@trinhcafe.vn"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Mật khẩu</label>
                <input 
                  type="password" 
                  className="w-full border border-gray-300 rounded-xl px-4 py-3 focus:ring-2 focus:ring-amber-500 focus:border-transparent transition-all duration-200" 
                  value={password} 
                  onChange={e=>setPassword(e.target.value)}
                  placeholder="••••••••"
                />
              </div>
            </div>
            
            <button 
              type="submit"
              className="w-full mt-6 px-4 py-3 rounded-xl bg-gradient-to-r from-amber-500 to-orange-500 text-white font-semibold hover:from-amber-600 hover:to-orange-600 transform hover:scale-105 transition-all duration-200 shadow-lg"
            >
              Đăng nhập
            </button>
          </form>
        </div>
      </div>
    </div>
  )
}
