const store = require('../models/store');
const { v4: uuidv4 } = require('uuid');

class DataRepository {
  // Users & Profiles
  findUserByEmail(email) {
    return store.data.users.find((u) => u.email.toLowerCase() === email.toLowerCase());
  }

  findUserById(id) {
    return store.data.users.find((u) => u.id === id);
  }

  findProfileByUserId(userId) {
    return store.data.profiles.find((p) => p.userId === userId);
  }

  createUser(userData, profileData) {
    const user = {
      id: userData.id || `usr_${uuidv4().substring(0, 8)}`,
      email: userData.email,
      password: userData.password,
      isOnline: true,
      lastSeen: new Date().toISOString(),
      createdAt: new Date().toISOString(),
    };
    const profile = {
      id: `prof_${uuidv4().substring(0, 8)}`,
      userId: user.id,
      fullName: profileData.fullName || 'New Student',
      university: profileData.university || 'Campus University',
      department: profileData.department || 'Engineering',
      year: profileData.year || '1st Year',
      bio: profileData.bio || '',
      profileImage: profileData.profileImage || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      skills: profileData.skills || [],
      interests: profileData.interests || [],
    };
    store.data.users.push(user);
    store.data.profiles.push(profile);
    store.save();
    return { user, profile };
  }

  updateProfile(userId, updates) {
    const profile = this.findProfileByUserId(userId);
    if (!profile) return null;
    Object.assign(profile, updates);
    store.save();
    return profile;
  }

  updateUserPresence(userId, isOnline) {
    const user = this.findUserById(userId);
    if (user) {
      user.isOnline = isOnline;
      user.lastSeen = new Date().toISOString();
      store.save();
    }
  }

  getAllStudents({ search, department, year, page = 1, limit = 20, excludeUserId }) {
    let list = store.data.profiles
      .filter((p) => !excludeUserId || p.userId !== excludeUserId)
      .map((p) => {
        const u = this.findUserById(p.userId);
        return {
          ...p,
          isOnline: u ? u.isOnline : false,
          lastSeen: u ? u.lastSeen : null,
          email: u ? u.email : '',
        };
      });

    if (search) {
      const q = search.toLowerCase();
      list = list.filter(
        (p) =>
          p.fullName.toLowerCase().includes(q) ||
          p.department.toLowerCase().includes(q) ||
          (p.skills && p.skills.some((s) => s.toLowerCase().includes(q))) ||
          (p.interests && p.interests.some((i) => i.toLowerCase().includes(q)))
      );
    }

    if (department && department !== 'All') {
      list = list.filter((p) => p.department.toLowerCase() === department.toLowerCase());
    }

    if (year && year !== 'All') {
      list = list.filter((p) => p.year.toLowerCase() === year.toLowerCase());
    }

    const startIndex = (page - 1) * limit;
    const paginated = list.slice(startIndex, startIndex + limit);
    return {
      data: paginated,
      total: list.length,
      page: Number(page),
      limit: Number(limit),
      hasNext: startIndex + limit < list.length,
    };
  }

  // Connections
  getConnections(userId) {
    return store.data.connections.filter(
      (c) => c.requesterId === userId || c.targetId === userId
    );
  }

  createConnection(requesterId, targetId) {
    const existing = store.data.connections.find(
      (c) =>
        (c.requesterId === requesterId && c.targetId === targetId) ||
        (c.requesterId === targetId && c.targetId === requesterId)
    );
    if (existing) return existing;
    const conn = {
      id: `conn_${uuidv4().substring(0, 8)}`,
      requesterId,
      targetId,
      status: 'PENDING',
      createdAt: new Date().toISOString(),
    };
    store.data.connections.push(conn);
    store.save();
    return conn;
  }

  removeConnection(requesterId, targetId) {
    const idx = store.data.connections.findIndex(
      (c) =>
        (c.requesterId === requesterId && c.targetId === targetId) ||
        (c.requesterId === targetId && c.targetId === requesterId)
    );
    if (idx !== -1) {
      store.data.connections.splice(idx, 1);
      store.save();
      return true;
    }
    return false;
  }

  // Communities
  getCommunities({ page = 1, limit = 20, userId }) {
    let list = store.data.communities.map((c) => {
      const isMember = userId
        ? store.data.communityMembers.some((cm) => cm.communityId === c.id && cm.userId === userId)
        : false;
      return { ...c, isMember };
    });
    const startIndex = (page - 1) * limit;
    return {
      data: list.slice(startIndex, startIndex + limit),
      total: list.length,
      page: Number(page),
      limit: Number(limit),
      hasNext: startIndex + limit < list.length,
    };
  }

  getCommunityById(id, userId) {
    const community = store.data.communities.find((c) => c.id === id);
    if (!community) return null;
    const members = store.data.communityMembers
      .filter((cm) => cm.communityId === id)
      .map((cm) => {
        const prof = this.findProfileByUserId(cm.userId);
        return {
          userId: cm.userId,
          role: cm.role,
          fullName: prof ? prof.fullName : 'Student',
          profileImage: prof ? prof.profileImage : null,
        };
      });
    const isMember = userId
      ? store.data.communityMembers.some((cm) => cm.communityId === id && cm.userId === userId)
      : false;
    return { ...community, members, isMember };
  }

  createCommunity(data, creatorId) {
    const community = {
      id: `comm_${uuidv4().substring(0, 8)}`,
      name: data.name,
      description: data.description,
      coverImage: data.coverImage || 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800',
      createdBy: creatorId,
      memberCount: 1,
      createdAt: new Date().toISOString(),
    };
    store.data.communities.push(community);
    store.data.communityMembers.push({
      id: `cm_${uuidv4().substring(0, 8)}`,
      communityId: community.id,
      userId: creatorId,
      role: 'ADMIN',
    });
    store.save();
    return community;
  }

  joinCommunity(communityId, userId) {
    const existing = store.data.communityMembers.find(
      (cm) => cm.communityId === communityId && cm.userId === userId
    );
    if (existing) return existing;
    const cm = {
      id: `cm_${uuidv4().substring(0, 8)}`,
      communityId,
      userId,
      role: 'MEMBER',
    };
    store.data.communityMembers.push(cm);
    const comm = store.data.communities.find((c) => c.id === communityId);
    if (comm) comm.memberCount = (comm.memberCount || 0) + 1;
    store.save();
    return cm;
  }

  leaveCommunity(communityId, userId) {
    const idx = store.data.communityMembers.findIndex(
      (cm) => cm.communityId === communityId && cm.userId === userId
    );
    if (idx !== -1) {
      store.data.communityMembers.splice(idx, 1);
      const comm = store.data.communities.find((c) => c.id === communityId);
      if (comm && comm.memberCount > 0) comm.memberCount -= 1;
      store.save();
      return true;
    }
    return false;
  }

  // Events
  getEvents({ category, filter, page = 1, limit = 20, userId }) {
    let list = store.data.events.map((e) => {
      const isRegistered = userId
        ? store.data.eventRegistrations.some((er) => er.eventId === e.id && er.userId === userId)
        : false;
      return { ...e, isRegistered };
    });

    if (category && category !== 'All') {
      list = list.filter((e) => e.category === category);
    }

    if (filter === 'registered' && userId) {
      list = list.filter((e) => e.isRegistered);
    } else if (filter === 'my' && userId) {
      list = list.filter((e) => e.createdBy === userId);
    }

    const startIndex = (page - 1) * limit;
    return {
      data: list.slice(startIndex, startIndex + limit),
      total: list.length,
      page: Number(page),
      limit: Number(limit),
      hasNext: startIndex + limit < list.length,
    };
  }

  getEventById(id, userId) {
    const event = store.data.events.find((e) => e.id === id);
    if (!event) return null;
    const isRegistered = userId
      ? store.data.eventRegistrations.some((er) => er.eventId === id && er.userId === userId)
      : false;
    const participants = store.data.eventRegistrations
      .filter((er) => er.eventId === id)
      .map((er) => {
        const prof = this.findProfileByUserId(er.userId);
        return {
          userId: er.userId,
          fullName: prof ? prof.fullName : 'Student',
          profileImage: prof ? prof.profileImage : null,
          registeredAt: er.registeredAt,
        };
      });
    return { ...event, isRegistered, participants };
  }

  createEvent(data, creatorId) {
    const event = {
      id: `evt_${uuidv4().substring(0, 8)}`,
      title: data.title,
      description: data.description,
      coverImage: data.coverImage || 'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=800',
      location: data.location || 'Campus Auditorium',
      startTime: data.startTime || new Date(Date.now() + 86400000 * 7).toISOString(),
      endTime: data.endTime || new Date(Date.now() + 86400000 * 7 + 14400000).toISOString(),
      capacity: Number(data.capacity) || 100,
      createdBy: creatorId,
      communityId: data.communityId || null,
      category: data.category || 'Technology',
      registeredCount: 0,
    };
    store.data.events.push(event);
    store.save();
    return event;
  }

  registerForEvent(eventId, userId) {
    const existing = store.data.eventRegistrations.find(
      (er) => er.eventId === eventId && er.userId === userId
    );
    if (existing) return existing;
    const reg = {
      id: `er_${uuidv4().substring(0, 8)}`,
      eventId,
      userId,
      registeredAt: new Date().toISOString(),
    };
    store.data.eventRegistrations.push(reg);
    const evt = store.data.events.find((e) => e.id === eventId);
    if (evt) evt.registeredCount = (evt.registeredCount || 0) + 1;
    store.save();
    return reg;
  }

  cancelEventRegistration(eventId, userId) {
    const idx = store.data.eventRegistrations.findIndex(
      (er) => er.eventId === eventId && er.userId === userId
    );
    if (idx !== -1) {
      store.data.eventRegistrations.splice(idx, 1);
      const evt = store.data.events.find((e) => e.id === eventId);
      if (evt && evt.registeredCount > 0) evt.registeredCount -= 1;
      store.save();
      return true;
    }
    return false;
  }

  // Conversations & Messages
  getConversations(userId) {
    return store.data.conversations
      .filter((c) => c.memberIds.includes(userId))
      .map((c) => {
        const lastMsg = store.data.messages
          .filter((m) => m.conversationId === c.id)
          .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))[0];
        
        let title = c.title;
        let avatar = null;
        let isOnline = false;

        if (!c.isGroup) {
          const otherUserId = c.memberIds.find((id) => id !== userId);
          if (otherUserId) {
            const otherProf = this.findProfileByUserId(otherUserId);
            const otherUser = this.findUserById(otherUserId);
            if (otherProf) {
              title = otherProf.fullName;
              avatar = otherProf.profileImage;
            }
            if (otherUser) {
              isOnline = otherUser.isOnline;
            }
          }
        } else {
          avatar = 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400';
        }

        return {
          ...c,
          title,
          avatar,
          isOnline,
          lastMessage: lastMsg ? lastMsg.content : null,
          lastMessageTime: lastMsg ? lastMsg.createdAt : c.updatedAt,
        };
      })
      .sort((a, b) => new Date(b.lastMessageTime) - new Date(a.lastMessageTime));
  }

  getMessages(conversationId, { page = 1, limit = 50 }) {
    const msgs = store.data.messages
      .filter((m) => m.conversationId === conversationId)
      .sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt));
    
    return msgs;
  }

  createMessage({ conversationId, senderId, content, messageType = 'TEXT' }) {
    const msg = {
      id: `msg_${uuidv4().substring(0, 8)}`,
      conversationId,
      senderId,
      content,
      messageType,
      status: 'SENT',
      createdAt: new Date().toISOString(),
    };
    store.data.messages.push(msg);

    const conv = store.data.conversations.find((c) => c.id === conversationId);
    if (conv) {
      conv.updatedAt = msg.createdAt;
    }
    store.save();
    return msg;
  }

  findOrCreateDirectConversation(userId, targetUserId) {
    let conv = store.data.conversations.find(
      (c) =>
        !c.isGroup &&
        c.memberIds.includes(userId) &&
        c.memberIds.includes(targetUserId)
    );
    if (!conv) {
      const targetProf = this.findProfileByUserId(targetUserId);
      conv = {
        id: `conv_${uuidv4().substring(0, 8)}`,
        isGroup: false,
        memberIds: [userId, targetUserId],
        title: targetProf ? targetProf.fullName : 'Chat',
        updatedAt: new Date().toISOString(),
      };
      store.data.conversations.push(conv);
      store.save();
    }
    return conv;
  }

  markMessagesAsRead(conversationId, readerId) {
    let count = 0;
    store.data.messages.forEach((m) => {
      if (m.conversationId === conversationId && m.senderId !== readerId && m.status !== 'READ') {
        m.status = 'READ';
        count++;
      }
    });
    if (count > 0) store.save();
    return count;
  }

  // Notifications
  getNotifications(userId) {
    return store.data.notifications
      .filter((n) => n.userId === userId)
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  }

  markNotificationAsRead(id, userId) {
    const notif = store.data.notifications.find((n) => n.id === id && n.userId === userId);
    if (notif) {
      notif.isRead = true;
      store.save();
      return notif;
    }
    return null;
  }

  createNotification({ userId, category, title, body, data }) {
    const notif = {
      id: `notif_${uuidv4().substring(0, 8)}`,
      userId,
      category,
      title,
      body,
      data: data || {},
      isRead: false,
      createdAt: new Date().toISOString(),
    };
    store.data.notifications.push(notif);
    store.save();
    return notif;
  }
}

module.exports = new DataRepository();
