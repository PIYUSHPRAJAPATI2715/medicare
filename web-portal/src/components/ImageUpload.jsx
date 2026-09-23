import React, { useRef, useState } from 'react';
import { Upload, Image as ImageIcon, X, Link, Check } from 'lucide-react';

export default function ImageUpload({
  label = 'Image',
  value = '',
  onChange,
  aspectRatio = 'aspect-video', // 'aspect-video' | 'aspect-square' | 'aspect-[4/3]'
  presets = [],
  placeholder = 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=600',
}) {
  const fileInputRef = useRef(null);
  const [showUrlInput, setShowUrlInput] = useState(false);
  const [urlDraft, setUrlDraft] = useState('');
  const [dragOver, setDragOver] = useState(false);

  const handleFileChange = (e) => {
    const file = e.target.files?.[0];
    if (file) {
      processFile(file);
    }
  };

  const processFile = (file) => {
    if (!file.type.startsWith('image/')) {
      alert('Please upload a valid image file (JPG, PNG, WebP).');
      return;
    }
    const reader = new FileReader();
    reader.onload = () => {
      if (typeof reader.result === 'string') {
        onChange(reader.result);
      }
    };
    reader.readAsDataURL(file);
  };

  const handleDrop = (e) => {
    e.preventDefault();
    setDragOver(false);
    const file = e.dataTransfer.files?.[0];
    if (file) {
      processFile(file);
    }
  };

  const handleApplyUrl = () => {
    if (urlDraft && urlDraft.trim()) {
      onChange(urlDraft.trim());
      setUrlDraft('');
      setShowUrlInput(false);
    }
  };

  return (
    <div className="space-y-2">
      <div className="flex justify-between items-center">
        <label className="block text-xs font-bold text-slate-700">{label}</label>
        <button
          type="button"
          onClick={() => setShowUrlInput(!showUrlInput)}
          className="text-[11px] font-bold text-blue-600 hover:text-blue-800 flex items-center gap-1 transition"
        >
          <Link className="w-3 h-3" />
          {showUrlInput ? 'Upload file instead' : 'Or paste URL'}
        </button>
      </div>

      {showUrlInput ? (
        <div className="flex gap-2">
          <input
            type="url"
            placeholder="https://example.com/photo.jpg"
            value={urlDraft}
            onChange={(e) => setUrlDraft(e.target.value)}
            className="flex-1 bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-xs font-medium focus:outline-none focus:border-blue-500"
          />
          <button
            type="button"
            onClick={handleApplyUrl}
            className="px-3 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition"
          >
            Apply
          </button>
        </div>
      ) : null}

      {/* Image Preview or Upload Dropzone */}
      {value ? (
        <div className={`relative ${aspectRatio} w-full rounded-2xl overflow-hidden border-2 border-slate-200 bg-slate-100 group shadow-sm`}>
          <img
            src={value}
            alt="Upload preview"
            className="w-full h-full object-cover"
            onError={(e) => {
              e.currentTarget.src = placeholder;
            }}
          />
          <div className="absolute inset-0 bg-slate-900/50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
            <button
              type="button"
              onClick={() => fileInputRef.current?.click()}
              className="px-3 py-1.5 bg-white text-slate-900 rounded-lg text-xs font-bold hover:bg-slate-100 transition shadow"
            >
              Change Photo
            </button>
            <button
              type="button"
              onClick={() => onChange('')}
              className="p-1.5 bg-red-600 text-white rounded-lg hover:bg-red-700 transition shadow"
              title="Remove image"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>
      ) : (
        <div
          onDragOver={(e) => {
            e.preventDefault();
            setDragOver(true);
          }}
          onDragLeave={() => setDragOver(false)}
          onDrop={handleDrop}
          onClick={() => fileInputRef.current?.click()}
          className={`border-2 border-dashed rounded-2xl p-4 sm:p-6 text-center cursor-pointer transition flex flex-col items-center justify-center gap-2 ${
            dragOver ? 'border-blue-500 bg-blue-50/50' : 'border-slate-200 hover:border-blue-400 bg-slate-50/50 hover:bg-white'
          }`}
        >
          <div className="w-10 h-10 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center">
            <Upload className="w-5 h-5" />
          </div>
          <div>
            <p className="text-xs font-bold text-slate-800">
              Click to upload <span className="text-slate-400 font-normal">or drag & drop</span>
            </p>
            <p className="text-[11px] text-slate-400 mt-0.5">PNG, JPG, WebP from your device</p>
          </div>
        </div>
      )}

      {/* Hidden File Input */}
      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        onChange={handleFileChange}
        className="hidden"
      />

      {/* Quick Image Presets */}
      {presets && presets.length > 0 ? (
        <div className="pt-1">
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">Or choose a preset:</p>
          <div className="flex gap-2 overflow-x-auto pb-1">
            {presets.map((preset, idx) => (
              <button
                key={idx}
                type="button"
                onClick={() => onChange(preset.url)}
                className={`relative rounded-xl overflow-hidden border-2 transition flex-shrink-0 w-16 h-12 ${
                  value === preset.url ? 'border-blue-600 ring-2 ring-blue-500/30' : 'border-slate-200 hover:border-slate-300'
                }`}
                title={preset.title || `Preset ${idx + 1}`}
              >
                <img src={preset.url} alt={preset.title || 'preset'} className="w-full h-full object-cover" />
                {value === preset.url && (
                  <div className="absolute inset-0 bg-blue-600/30 flex items-center justify-center">
                    <Check className="w-3.5 h-3.5 text-white stroke-[3]" />
                  </div>
                )}
              </button>
            ))}
          </div>
        </div>
      ) : null}
    </div>
  );
}
