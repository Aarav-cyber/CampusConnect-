const fs = require('fs');
const path = require('path');

const DB_DIR = path.resolve(__dirname, '../../data');
const DB_FILE = path.join(DB_DIR, 'campusconnect_db.json');

const INITIAL_DATA = {
  users: [
    {
      id: 'usr_aarav',
      email: 'aarav@university.edu',
      password: 'password123',
      isOnline: false,
      lastSeen: new Date().toISOString(),
      createdAt: '2026-09-01T08:00:00.000Z',
    },
    {
      id: 'usr_rahul',
      email: 'rahul@university.edu',
      password: 'password123',
      isOnline: true,
      lastSeen: new Date().toISOString(),
      createdAt: '2026-09-02T09:00:00.000Z',
    },
    {
      id: 'usr_anjali',
      email: 'anjali@university.edu',
      password: 'password123',
      isOnline: true,
      lastSeen: new Date().toISOString(),
      createdAt: '2026-09-03T10:00:00.000Z',
    },
    {
      id: 'usr_ankush',
      email: 'ankush@university.edu',
      password: 'password123',
      isOnline: false,
      lastSeen: new Date().toISOString(),
      createdAt: '2026-09-04T11:00:00.000Z',
    },
    {
      id: 'usr_riju',
      email: 'riju@university.edu',
      password: 'password123',
      isOnline: false,
      lastSeen: new Date().toISOString(),
      createdAt: '2026-09-05T12:00:00.000Z',
    },
  ],
  profiles: [
    {
      id: 'prof_aarav',
      userId: 'usr_aarav',
      fullName: 'Aarav Shrestha',
      university: 'SRM University-AP',
      department: 'Computer Science',
      year: '3rd Year',
      bio: 'Fullstack & Flutter explorer. Passionate about distributed systems, real-time apps & AI.',
      profileImage: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      skills: ['Flutter', 'Dart', 'Python', 'Machine Learning', 'Node.js'],
      interests: ['AI', 'Open Source', 'Hackathons', 'Mobile Dev'],
    },
    {
      id: 'prof_rahul',
      userId: 'usr_rahul',
      fullName: 'Rahul Kumar',
      university: 'SRM University-AP',
      department: 'AI & Data Science',
      year: '2nd Year',
      bio: 'Deep learning researcher and competitive coder. Always up for hackathon collabs!',
      profileImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      skills: ['Python', 'TensorFlow', 'PyTorch', 'Data Analytics', 'C++'],
      interests: ['Computer Vision', 'Deep Learning', 'Kaggle', 'Chess'],
    },
    {
      id: 'prof_anjali',
      userId: 'usr_anjali',
      fullName: 'Anjali Sharma',
      university: 'SRM University-AP',
      department: 'Computer Science',
      year: '3rd Year',
      bio: 'Frontend enthusiast & UI/UX designer. Making products visually stunning and accessible.',
      profileImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      skills: ['Figma', 'Flutter', 'React', 'CSS Art', 'Design Systems'],
      interests: ['UI/UX', 'Product Design', 'Photography', 'Music'],
    },
    {
      id: 'prof_ankush',
      userId: 'usr_ankush',
      fullName: 'Ankush Roy',
      university: 'SRM University-AP',
      department: 'Cyber Security',
      year: '4th Year',
      bio: 'CTF player, ethical hacker & security auditor. President of University Cyber Club.',
      profileImage: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      skills: ['Network Security', 'Penetration Testing', 'Linux', 'Cryptography', 'Go'],
      interests: ['CTFs', 'Bug Bounties', 'Reverse Engineering', 'DevOps'],
    },
    {
      id: 'prof_riju',
      userId: 'usr_riju',
      fullName: 'Riju Das',
      university: 'SRM University-AP',
      department: 'Electronics & Comm',
      year: '3rd Year',
      bio: 'Embedded systems engineer & IoT maker. Hardware meets modern cloud.',
      profileImage: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=400',
      skills: ['Arduino', 'Raspberry Pi', 'Embedded C', 'MQTT', 'Robotics'],
      interests: ['Robotics', 'Drones', 'Automation', '3D Printing'],
    },
  ],
  connections: [
    { id: 'conn_1', requesterId: 'usr_aarav', targetId: 'usr_rahul', status: 'ACCEPTED' },
    { id: 'conn_2', requesterId: 'usr_aarav', targetId: 'usr_anjali', status: 'ACCEPTED' },
    { id: 'conn_3', requesterId: 'usr_ankush', targetId: 'usr_aarav', status: 'PENDING' },
  ],
  communities: [
    {
      id: 'comm_flutter',
      name: 'Flutter Developers SRM',
      description: 'The premier community for cross-platform app developers, widget artisans, and Dart lovers.',
      coverImage: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800',
      createdBy: 'usr_aarav',
      memberCount: 84,
      createdAt: '2026-08-15T10:00:00.000Z',
    },
    {
      id: 'comm_ai',
      name: 'AI & Machine Learning Club',
      description: 'Exploring LLMs, neural networks, computer vision, and autonomous agents on campus.',
      coverImage: 'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=800',
      createdBy: 'usr_rahul',
      memberCount: 156,
      createdAt: '2026-08-10T10:00:00.000Z',
    },
    {
      id: 'comm_cyber',
      name: 'Cyber Security & Ethical Hacking',
      description: 'Campus defense squadron, CTF training, security workshops, and white-hat research.',
      coverImage: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800',
      createdBy: 'usr_ankush',
      memberCount: 92,
      createdAt: '2026-08-12T10:00:00.000Z',
    },
    {
      id: 'comm_robotics',
      name: 'Robotics & Automation Society',
      description: 'Designing autonomous rovers, combat bots, and IoT smart campus prototypes.',
      coverImage: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800',
      createdBy: 'usr_riju',
      memberCount: 68,
      createdAt: '2026-08-20T10:00:00.000Z',
    },
  ],
  communityMembers: [
    { id: 'cm_1', communityId: 'comm_flutter', userId: 'usr_aarav', role: 'ADMIN' },
    { id: 'cm_2', communityId: 'comm_flutter', userId: 'usr_anjali', role: 'MEMBER' },
    { id: 'cm_3', communityId: 'comm_ai', userId: 'usr_rahul', role: 'ADMIN' },
    { id: 'cm_4', communityId: 'comm_ai', userId: 'usr_aarav', role: 'MEMBER' },
    { id: 'cm_5', communityId: 'comm_cyber', userId: 'usr_ankush', role: 'ADMIN' },
    { id: 'cm_6', communityId: 'comm_robotics', userId: 'usr_riju', role: 'ADMIN' },
  ],
  events: [
    {
      id: 'evt_hacksrm',
      title: 'HackSRM 2026',
      description: 'Annual 36-hour flagship hackathon. Build next-gen campus, fintech, healthcare, and AI solutions with $10,000+ in prizes!',
      coverImage: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800',
      location: 'University Auditorium & Innovation Wing',
      startTime: '2026-10-20T09:00:00.000Z',
      endTime: '2026-10-21T21:00:00.000Z',
      capacity: 350,
      createdBy: 'usr_aarav',
      communityId: 'comm_flutter',
      category: 'Hackathons',
      registeredCount: 245,
    },
    {
      id: 'evt_flutter_conf',
      title: 'Flutter Forward Campus Workshop',
      description: 'Hands-on deep dive into Flutter 3.x, Riverpod state management, and real-time WebSockets integration.',
      coverImage: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800',
      location: 'Lab Block 3, Room 402',
      startTime: '2026-10-05T14:00:00.000Z',
      endTime: '2026-10-05T18:00:00.000Z',
      capacity: 80,
      createdBy: 'usr_aarav',
      communityId: 'comm_flutter',
      category: 'Workshops',
      registeredCount: 72,
    },
    {
      id: 'evt_ai_summit',
      title: 'Generative AI & LLM Symposium',
      description: 'Keynotes from industry leaders on deploying multimodal agents and fine-tuning open source models.',
      coverImage: 'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=800',
      location: 'Main Seminar Hall 1',
      startTime: '2026-10-12T10:00:00.000Z',
      endTime: '2026-10-12T16:00:00.000Z',
      capacity: 200,
      createdBy: 'usr_rahul',
      communityId: 'comm_ai',
      category: 'Technology',
      registeredCount: 160,
    },
    {
      id: 'evt_ctf_defense',
      title: 'Campus Cyber Siege (CTF)',
      description: 'Capture-the-flag tournament testing web exploitation, reverse engineering, and binary analysis.',
      coverImage: 'https://images.unsplash.com/photo-1510511459019-5dda7724fd87?w=800',
      location: 'Server Room Arena & Discord',
      startTime: '2026-10-15T18:00:00.000Z',
      endTime: '2026-10-16T06:00:00.000Z',
      capacity: 120,
      createdBy: 'usr_ankush',
      communityId: 'comm_cyber',
      category: 'Competitions',
      registeredCount: 95,
    },
  ],
  eventRegistrations: [
    { id: 'er_1', eventId: 'evt_hacksrm', userId: 'usr_aarav', registeredAt: '2026-09-20T10:00:00.000Z' },
    { id: 'er_2', eventId: 'evt_hacksrm', userId: 'usr_rahul', registeredAt: '2026-09-21T11:00:00.000Z' },
    { id: 'er_3', eventId: 'evt_flutter_conf', userId: 'usr_aarav', registeredAt: '2026-09-22T09:00:00.000Z' },
  ],
  conversations: [
    {
      id: 'conv_aarav_rahul',
      isGroup: false,
      memberIds: ['usr_aarav', 'usr_rahul'],
      title: 'Rahul Kumar',
      updatedAt: '2026-09-28T10:15:00.000Z',
    },
    {
      id: 'conv_aarav_anjali',
      isGroup: false,
      memberIds: ['usr_aarav', 'usr_anjali'],
      title: 'Anjali Sharma',
      updatedAt: '2026-09-28T09:40:00.000Z',
    },
    {
      id: 'conv_flutter_group',
      isGroup: true,
      communityId: 'comm_flutter',
      memberIds: ['usr_aarav', 'usr_rahul', 'usr_anjali', 'usr_ankush'],
      title: 'Flutter Developers Hub',
      updatedAt: '2026-09-28T11:20:00.000Z',
    },
  ],
  messages: [
    {
      id: 'msg_101',
      conversationId: 'conv_aarav_rahul',
      senderId: 'usr_rahul',
      content: 'Hey Aarav! Are you teaming up for HackSRM 2026?',
      messageType: 'TEXT',
      status: 'READ',
      createdAt: '2026-09-28T10:10:00.000Z',
    },
    {
      id: 'msg_102',
      conversationId: 'conv_aarav_rahul',
      senderId: 'usr_aarav',
      content: 'Hey Rahul! Yes, absolutely. We need to integrate AI agent workflows into our Flutter app.',
      messageType: 'TEXT',
      status: 'READ',
      createdAt: '2026-09-28T10:12:00.000Z',
    },
    {
      id: 'msg_103',
      conversationId: 'conv_aarav_rahul',
      senderId: 'usr_rahul',
      content: 'Awesome! I can prepare the local model inference endpoints.',
      messageType: 'TEXT',
      status: 'READ',
      createdAt: '2026-09-28T10:15:00.000Z',
    },
    {
      id: 'msg_201',
      conversationId: 'conv_aarav_anjali',
      senderId: 'usr_anjali',
      content: 'Shared the new design kit for CampusConnect on Figma!',
      messageType: 'TEXT',
      status: 'READ',
      createdAt: '2026-09-28T09:40:00.000Z',
    },
    {
      id: 'msg_301',
      conversationId: 'conv_flutter_group',
      senderId: 'usr_aarav',
      content: 'Welcome everyone to the official Flutter Community channel! Workshop details are posted under Events.',
      messageType: 'TEXT',
      status: 'DELIVERED',
      createdAt: '2026-09-28T11:20:00.000Z',
    },
  ],
  notifications: [
    {
      id: 'notif_1',
      userId: 'usr_aarav',
      category: 'EVENTS',
      title: 'HackSRM 2026 Registration Confirmed',
      body: 'Your registration for HackSRM 2026 has been approved! Check your schedule.',
      isRead: false,
      createdAt: '2026-09-28T08:30:00.000Z',
    },
    {
      id: 'notif_2',
      userId: 'usr_aarav',
      category: 'CONNECTIONS',
      title: 'New Connection Request',
      body: 'Ankush Roy sent you a connection request.',
      isRead: false,
      createdAt: '2026-09-28T09:15:00.000Z',
    },
    {
      id: 'notif_3',
      userId: 'usr_aarav',
      category: 'COMMUNITIES',
      title: 'Flutter Workshop Announcement',
      body: 'Hands-on Flutter workshop registration is now open.',
      isRead: true,
      createdAt: '2026-09-27T16:00:00.000Z',
    },
  ],
};

class Store {
  constructor() {
    this.data = JSON.parse(JSON.stringify(INITIAL_DATA));
    this.load();
  }

  load() {
    try {
      if (fs.existsSync(DB_FILE)) {
        const raw = fs.readFileSync(DB_FILE, 'utf-8');
        this.data = JSON.parse(raw);
      } else {
        this.save();
      }
    } catch (e) {
      console.error('Error loading DB file, fallback to initial data', e);
      this.data = JSON.parse(JSON.stringify(INITIAL_DATA));
    }
  }

  save() {
    try {
      if (!fs.existsSync(DB_DIR)) {
        fs.mkdirSync(DB_DIR, { recursive: true });
      }
      fs.writeFileSync(DB_FILE, JSON.stringify(this.data, null, 2), 'utf-8');
    } catch (e) {
      console.error('Error saving DB file', e);
    }
  }
}

const store = new Store();
module.exports = store;
