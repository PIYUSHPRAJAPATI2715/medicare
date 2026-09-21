import React, { useState, useEffect } from 'react';
import { Video, Mic, MicOff, Camera, PhoneOff, FileText, Send, CheckCircle, ShieldCheck } from 'lucide-react';
import { doctorApiService } from '../services/api';

export default function VideoCallRoomPage({ appointment, onEndCall }) {
  const [micMuted, setMicMuted] = useState(false);
  const [camOff, setCamOff] = useState(false);
  const [prescription, setPrescription] = useState('Tab Paracetamol 650mg - 1 tablet BD after food for 3 days.\nDrink plenty of warm fluids and rest.');
  const [chatInput, setChatInput] = useState('');
  const [chatMessages, setChatMessages] = useState([
    { sender: 'Patient', text: 'Hello Doctor! I have a fever and headache since yesterday evening.' },
    { sender: 'Dr. Rajesh Sharma', text: 'Hello Piyush! Let me check your symptoms. Do you also have cold or body ache?' },
  ]);
  const [presSaved, setPresSaved] = useState(false);
  const [agoraToken, setAgoraToken] = useState(null);

  useEffect(() => {
    fetchToken();
  }, []);

  const fetchToken = async () => {
    const channel = appointment?.agoraChannelName || 'medicare_call_apt-101';
    const res = await doctorApiService.generateAgoraRtcToken(channel, 1002);
    if (res.success) {
      setAgoraToken(res.token);
    }
  };

  const handleSendMessage = (e) => {
    e.preventDefault();
    if (!chatInput) return;
    setChatMessages([...chatMessages, { sender: 'Dr. Rajesh Sharma', text: chatInput }]);
    setChatInput('');
  };

  const handleSavePrescription = async () => {
    if (appointment?.id) {
      await doctorApiService.updateAppointmentStatus(appointment.id, 'completed', prescription);
    }
    setPresSaved(true);
    setTimeout(() => setPresSaved(false), 3000);
  };

  return (
    <div className="h-[calc(100vh-5rem)] flex flex-col lg:flex-row gap-4">
      {/* Video Call Screen */}
      <div className="flex-1 bg-slate-950 rounded-2xl relative overflow-hidden flex flex-col justify-between p-4 border border-slate-800 shadow-2xl">
        {/* Header Overlay */}
        <div className="flex items-center justify-between z-10 bg-slate-900/80 backdrop-blur-md p-3 rounded-xl border border-white/10">
          <div className="flex items-center gap-3">
            <div className="w-3 h-3 rounded-full bg-emerald-500 animate-ping"></div>
            <div>
              <h3 className="text-white font-bold text-sm">Agora HD Video Call • Piyush Prajapati</h3>
              <p className="text-slate-400 text-xs font-medium">Channel: {appointment?.agoraChannelName || 'medicare_room_101'}</p>
            </div>
          </div>
          <span className="bg-emerald-500/20 text-emerald-400 text-xs font-extrabold px-3 py-1 rounded-lg border border-emerald-500/30">
            04:25 LIVE
          </span>
        </div>

        {/* Video Canvas Simulation */}
        <div className="absolute inset-0 flex items-center justify-center">
          {!camOff ? (
            <div className="w-full h-full relative">
              <img
                src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=1200"
                alt="Patient Stream"
                className="w-full h-full object-cover filter contrast-105"
              />
              {/* Doctor PiP Thumbnail */}
              <div className="absolute bottom-20 right-4 w-40 h-28 rounded-xl overflow-hidden border-2 border-white/40 shadow-2xl bg-slate-900">
                <img
                  src="https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400"
                  alt="Doctor Stream"
                  className="w-full h-full object-cover"
                />
              </div>
            </div>
          ) : (
            <div className="text-center text-slate-500">
              <Video className="w-16 h-16 mx-auto text-slate-700 mb-2" />
              <p className="font-bold">Camera Turned Off</p>
            </div>
          )}
        </div>

        {/* Controls Floating Bar */}
        <div className="z-10 flex items-center justify-center gap-4 bg-slate-900/90 backdrop-blur-md p-3 rounded-2xl border border-white/10 max-w-md mx-auto w-full">
          <button
            onClick={() => setMicMuted(!micMuted)}
            className={`p-3.5 rounded-xl font-bold transition-all ${
              micMuted ? 'bg-red-500 text-white' : 'bg-slate-800 text-slate-200 hover:bg-slate-700'
            }`}
          >
            {micMuted ? <MicOff className="w-5 h-5" /> : <Mic className="w-5 h-5" />}
          </button>

          <button
            onClick={() => setCamOff(!camOff)}
            className={`p-3.5 rounded-xl font-bold transition-all ${
              camOff ? 'bg-red-500 text-white' : 'bg-slate-800 text-slate-200 hover:bg-slate-700'
            }`}
          >
            <Camera className="w-5 h-5" />
          </button>

          <button
            onClick={onEndCall}
            className="flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white px-6 py-3 rounded-xl font-extrabold text-sm shadow-lg shadow-red-600/30"
          >
            <PhoneOff className="w-5 h-5" /> End Consultation
          </button>
        </div>
      </div>

      {/* Doctor Side Drawer: Prescription Builder & Patient Chat */}
      <div className="w-full lg:w-96 flex flex-col gap-4">
        {/* Prescription Writer */}
        <div className="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-sm space-y-3">
          <div className="flex items-center justify-between">
            <h3 className="font-extrabold text-slate-900 text-sm flex items-center gap-2">
              <FileText className="w-4 h-4 text-blue-600" /> Electronic Prescription
            </h3>
            {presSaved && <span className="text-xs font-bold text-emerald-600 flex items-center gap-1"><CheckCircle className="w-3.5 h-3.5" /> Saved</span>}
          </div>
          <textarea
            rows="4"
            value={prescription}
            onChange={(e) => setPrescription(e.target.value)}
            className="w-full border border-slate-200 rounded-xl p-3 text-xs font-medium text-slate-800 focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Write diagnosis and medicines..."
          />
          <button
            onClick={handleSavePrescription}
            className="w-full py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold text-xs shadow-md shadow-blue-500/20"
          >
            Save Prescription to Patient Record
          </button>
        </div>

        {/* Live Chat Box */}
        <div className="flex-1 bg-white rounded-2xl p-4 border border-slate-200/80 shadow-sm flex flex-col justify-between">
          <h3 className="font-extrabold text-slate-900 text-xs uppercase tracking-wider mb-2">In-Call Chat</h3>
          <div className="flex-1 overflow-y-auto space-y-2 pr-1 my-2">
            {chatMessages.map((msg, i) => (
              <div
                key={i}
                className={`p-2.5 rounded-xl text-xs ${
                  msg.sender === 'Patient' ? 'bg-slate-100 text-slate-800 self-start' : 'bg-blue-600 text-white ml-6 font-medium'
                }`}
              >
                <p className="font-bold text-[10px] opacity-75">{msg.sender}</p>
                <p className="mt-0.5">{msg.text}</p>
              </div>
            ))}
          </div>
          <form onSubmit={handleSendMessage} className="flex gap-2">
            <input
              type="text"
              placeholder="Type message..."
              value={chatInput}
              onChange={(e) => setChatInput(e.target.value)}
              className="flex-1 border border-slate-200 rounded-xl px-3 py-2 text-xs focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            <button type="submit" className="p-2 bg-blue-600 text-white rounded-xl">
              <Send className="w-4 h-4" />
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
