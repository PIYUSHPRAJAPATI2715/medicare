import React, { createContext, useContext, useState } from 'react';

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(() => {
    const saved = localStorage.getItem('drconnects24_user');
    if (saved) {
      try { return JSON.parse(saved); } catch (_) {}
    }
    // Default logged in as Admin for instant access
    return {
      name: 'System Administrator',
      email: 'admin@drconnects24.com',
      role: 'admin',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    };
  });

  const login = (role, email, name) => {
    const newUser = {
      name: name || (role === 'doctor' ? 'Dr. Rajesh Sharma' : 'System Administrator'),
      email: email || (role === 'doctor' ? 'dr.rajesh@drconnects24.com' : 'admin@drconnects24.com'),
      role,
      avatarUrl: role === 'doctor'
        ? 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400'
        : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    };
    setUser(newUser);
    localStorage.setItem('drconnects24_user', JSON.stringify(newUser));
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem('drconnects24_user');
  };

  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
