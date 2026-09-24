import { initialUsers } from './data.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  const id = req.query.id || req.body?.id;

  // GET: single user by ID or all users
  if (req.method === 'GET') {
    if (id) {
      const user = initialUsers.find(u => u.id === id);
      if (!user) {
        return res.status(404).json({
          status: 404,
          success: false,
          message: 'User profile not found',
          data: null,
        });
      }
      return res.status(200).json({
        status: 200,
        success: true,
        message: 'User profile retrieved successfully',
        data: { user },
      });
    }

    return res.status(200).json({
      status: 200,
      success: true,
      message: 'Users list retrieved successfully',
      count: initialUsers.length,
      data: initialUsers,
    });
  }

  // PUT: update user profile
  if (req.method === 'PUT') {
    if (!id) {
      return res.status(400).json({
        status: 400,
        success: false,
        message: 'User ID is required for updating profile',
        data: null,
      });
    }

    const idx = initialUsers.findIndex(u => u.id === id);
    if (idx === -1) {
      return res.status(404).json({
        status: 404,
        success: false,
        message: 'User not found to update',
        data: null,
      });
    }

    initialUsers[idx] = { ...initialUsers[idx], ...req.body, id };

    return res.status(200).json({
      status: 200,
      success: true,
      message: 'User profile updated successfully',
      data: initialUsers[idx],
    });
  }

  // DELETE: delete user
  if (req.method === 'DELETE') {
    if (!id) {
      return res.status(400).json({
        status: 400,
        success: false,
        message: 'User ID is required for deleting account',
        data: null,
      });
    }

    const idx = initialUsers.findIndex(u => u.id === id);
    if (idx !== -1) {
      initialUsers.splice(idx, 1);
    }

    return res.status(200).json({
      status: 200,
      success: true,
      message: 'User account deleted successfully',
      data: { id, deleted: true },
    });
  }

  // POST: create user
  if (req.method === 'POST') {
    const newUser = { id: `u_${Date.now()}`, ...req.body };
    initialUsers.unshift(newUser);
    return res.status(201).json({
      status: 201,
      success: true,
      message: 'User created successfully',
      data: newUser,
    });
  }

  return res.status(405).json({
    status: 405,
    success: false,
    message: 'Method not allowed',
    data: null,
  });
}
