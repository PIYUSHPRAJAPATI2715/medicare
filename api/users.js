import { getUsers, getUserById, addUser, updateUser, deleteUser } from './store.js';

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
      const user = getUserById(id);
      if (!user) {
        return res.status(404).json({
          status: 404,
          statusCode: 404,
          success: false,
          message: 'User profile not found',
          data: null,
        });
      }
      return res.status(200).json({
        status: 200,
        statusCode: 200,
        success: true,
        message: 'User profile retrieved successfully',
        data: { user },
      });
    }

    const allUsers = getUsers();
    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'Users list retrieved successfully',
      count: allUsers.length,
      data: allUsers,
    });
  }

  // PUT: update user profile
  if (req.method === 'PUT') {
    if (!id) {
      return res.status(400).json({
        status: 400,
        statusCode: 400,
        success: false,
        message: 'User ID is required for updating profile',
        data: null,
      });
    }

    const updated = updateUser(id, req.body || {});
    if (!updated) {
      return res.status(404).json({
        status: 404,
        statusCode: 404,
        success: false,
        message: 'User not found to update',
        data: null,
      });
    }

    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'User profile updated successfully',
      data: updated,
    });
  }

  // DELETE: delete user
  if (req.method === 'DELETE') {
    if (!id) {
      return res.status(400).json({
        status: 400,
        statusCode: 400,
        success: false,
        message: 'User ID is required for deleting account',
        data: null,
      });
    }

    const ok = deleteUser(id);
    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: ok ? 'User account deleted successfully' : 'User removed from directory',
      data: { id, deleted: true },
    });
  }

  // POST: create user / register
  if (req.method === 'POST') {
    const newUser = addUser(req.body || {});
    return res.status(201).json({
      status: 201,
      statusCode: 201,
      success: true,
      message: 'User created successfully',
      data: newUser,
    });
  }

  return res.status(405).json({
    status: 405,
    statusCode: 405,
    success: false,
    message: 'Method not allowed',
    data: null,
  });
}
