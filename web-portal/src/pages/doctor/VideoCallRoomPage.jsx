import React, { useState } from 'react';
import { useParams, useNavigate } from 'react';
import { Video, Mic, MicOff, VideoOff, PhoneOff, FileText, Send, Check } from 'lucide-react';

export default function VideoCallRoomPage() {
  const [isMuted, setIsMuted] = useState(false);
  const [isVideoOff, setIsVideoOff] = useState(false);
  const [diagnosis, setDiagnosis] = useState('');
  const [medicines, setMedicines] = useState('');
  const [rxSent, setRxSent] = useState(false);

  const handleSendRx = (e) => {
    e.preventDefault();
    setRxSent(true);
    setTimeout(() => setRxSent(false), 3000);
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <span className="text-[10px] font-extrabold uppercase tracking-wider text-blue-600 bg-blue-50 px-2 py-0.5 rounded">
            Live Consult Room · Agora RTC HD
          </span>
          <h1 className="text-xl font-black text-slate-900 mt-1">Patient Consultation: Piyush Prajapati</h1>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Video Screen Column */}
        <div className="lg:col-span-2 space-y-4">
          <div className="bg-slate-900 rounded-3xl overflow-hidden aspect-video relative shadow-2xl border border-slate-800 flex items-center justify-center">
            {/* Main Remote Video Stream */}
            <img
              src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800"
              alt="Patient Stream"
              className="w-full h-full object-cover"
            />
            <div className="absolute top-4 left-4 bg-slate-950/70 backdrop-blur-md border border-slate-700/60 px-3 py-1.5 rounded-xl text-white text-xs font-bold flex items-center gap-2">
              <span className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse" />
              Piyush Prajapati (Patient)
            </div>

            {/* Doctor Self Picture-in-Picture Stream */}
            <div className="absolute bottom-4 right-4 w-36 h-28 bg-slate-950 border-2 border-white/20 rounded-2xl overflow-hidden shadow-xl">
              <img
                src="https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400"
                alt="Doctor Self"
                className="w-full h-full object-cover"
              />
            </div>

            {/* In-Call Action Control Bar */}
            <div className="absolute bottom-4 left-1/2 -translate-x-1/2 bg-slate-950/80 backdrop-blur-md border border-slate-700 px-4 py-2 rounded-2xl flex items-center gap-3 shadow-2xl">
              <button
                onClick={() => setIsMuted(!isMuted)}
                className={`p-3 rounded-xl text-white transition ${isMuted ? 'bg-red-600' : 'bg-slate-800 hover:bg-slate-700'}`}
              >
                {isMuted ? <MicOff className="w-5 h-5" /> : <Mic className="w-5 h-5" />}
              </button>
              <button
                onClick={() => setIsVideoOff(!isVideoOff)}
                className={`p-3 rounded-xl text-white transition ${isVideoOff ? 'bg-red-600' : 'bg-slate-800 hover:bg-slate-700'}`}
              >
                {isVideoOff ? <VideoOff className="w-5 h-5" /> : <Video className="w-5 h-5" />}
              </button>
              <a
                href="/doctor/dashboard"
                className="p-3 bg-red-600 hover:bg-red-700 text-white rounded-xl font-bold transition flex items-center gap-2 px-4 text-xs"
              >
                <PhoneOff className="w-5 h-5" /> End Call
              </a>
            </div>
          </div>
        </div>

        {/* Electronic Prescription Writer Column */}
        <div className="bg-white rounded-3xl border border-slate-200 p-6 shadow-sm space-y-4">
          <div className="flex items-center gap-2 border-b border-slate-100 pb-3">
            <FileText className="w-5 h-5 text-blue-600" />
            <h3 className="text-base font-extrabold text-slate-900">Electronic Prescription</h3>
          </div>

          <form onSubmit={handleSendRx} className="space-y-4">
            <div>
              <label className="block text-xs font-bold text-slate-700 mb-1">Clinical Diagnosis</label>
              <textarea
                required
                rows={2}
                placeholder="e.g. Viral Fever & Upper Respiratory Tract Infection"
                value={diagnosis}
                onChange={(e) => setDiagnosis(e.target.value)}
                className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3 text-xs font-medium focus:outline-none focus:border-blue-500"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 mb-1">Prescribed Medicines & Dosage</label>
              <textarea
                required
                rows={4}
                placeholder="1. Tab Paracetamol 650mg - 1-0-1 after meals (3 days)&#10;2. Tab Cetirizine 10mg - 0-0-1 at night (5 days)"
                value={medicines}
                onChange={(e) => setMedicines(e.target.value)}
                className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3 text-xs font-medium focus:outline-none focus:border-blue-500"
              />
            </div>

            <button
              type="submit"
              className={`w-full py-3 px-4 rounded-xl text-xs font-extrabold text-white flex items-center justify-center gap-2 transition ${
                rxSent ? 'bg-emerald-600' : 'bg-blue-600 hover:bg-blue-700 shadow-md shadow-blue-600/20'
              }`}
            >
              {rxSent ? <Check className="w-4 h-4" /> : <Send className="w-4 h-4" />}
              {rxSent ? 'Prescription Issued to Patient Record!' : 'Issue Digital Prescription'}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
