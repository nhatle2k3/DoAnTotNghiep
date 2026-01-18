// import React, { useEffect, useState } from 'react';
// import NavBar from '../components/NavBar';
// import Orders from './Orders';
// import Tables from './Tables';
// import Menu from './Menu';
// import MenuManagement from '../components/MenuManagement';
// import CategoryManagement from '../components/CategoryManagement';
// import Reports from './Reports';

// export default function Dashboard({ token, user, onLogout }) {
//   const [current, setCurrent] = useState('Orders');
//   return (
//     <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 content-has-bottom-bar">
//       <NavBar user={user} current={current} setCurrent={setCurrent} onLogout={onLogout} />
//       <div className="max-w-7xl mx-auto px-4 sm:px-6 py-4 sm:py-8">
//         <div className="animate-fadeIn">
//           {current==='Orders' && <Orders token={token} />}
//           {current==='Tables' && <Tables token={token} />}
//           {current==='Menu' && <Menu token={token} user={user} />}
//           {current==='MenuManagement' && <MenuManagement user={user} token={token} />}
//           {current==='CategoryManagement' && <CategoryManagement user={user} token={token} />}
//           {current==='Reports' && <Reports token={token} />}
//         </div>
//       </div>
//     </div>
//   )
// }
import React, { useState } from 'react';
import NavBar from '../components/NavBar';
import Orders from './Orders';
import Tables from './Tables';
import Menu from './Menu';
import MenuManagement from '../components/MenuManagement';
import CategoryManagement from '../components/CategoryManagement';
import Reports from './Reports';
import Customers from './Customers';
import Staff from './Staff';

export default function Dashboard({ token, user, onLogout }) {
  const [current, setCurrent] = useState('Orders');

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 content-has-bottom-bar">
      <NavBar user={user} current={current} setCurrent={setCurrent} onLogout={onLogout} />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 py-4 sm:py-8">
        <div className="animate-fadeIn">
          {current === 'Orders' && <Orders token={token} />}
          {current === 'Tables' && <Tables token={token} />}
          {current === 'Menu' && <Menu token={token} user={user} onLogout={onLogout} />}
          {current === 'MenuManagement' && <MenuManagement user={user} token={token} />}
          {current === 'CategoryManagement' && <CategoryManagement user={user} token={token} />}
          {current === 'Customers' && <Customers token={token} />}
          {current === 'Staff' && <Staff token={token} />}
          {current === 'Reports' && <Reports token={token} />}
        </div>
      </div>
    </div>
  );
}
