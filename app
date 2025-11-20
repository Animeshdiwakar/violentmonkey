import React, { useState, useEffect, useRef } from 'react';
import { 
  Search, 
  ArrowLeft, 
  ArrowRight, 
  RotateCw, 
  ShieldCheck, 
  Lock, 
  X, 
  Menu, 
  Puzzle, 
  Star,
  Home,
  Youtube,
  AlertTriangle
} from 'lucide-react';

// --- Components ---

const Tab = ({ title, active, onClose }) => (
  <div className={`group flex items-center max-w-[200px] min-w-[120px] h-9 px-3 rounded-t-lg text-sm select-none cursor-default transition-colors ${active ? 'bg-[#42414d] text-white' : 'bg-transparent text-gray-400 hover:bg-[#302f36]'}`}>
    <div className="flex items-center gap-2 overflow-hidden flex-1">
      <Youtube size={14} className="text-[#ff0033] shrink-0" />
      <span className="truncate">{title}</span>
    </div>
    <button onClick={onClose} className={`ml-2 p-0.5 rounded-sm hover:bg-white/20 ${active ? 'opacity-100' : 'opacity-0 group-hover:opacity-100'}`}>
      <X size={12} />
    </button>
  </div>
);

const IconButton = ({ icon: Icon, size = 18, className = "", onClick, disabled }) => (
  <button 
    onClick={onClick}
    disabled={disabled}
    className={`p-1.5 rounded-[4px] hover:bg-[#52525e] text-gray-300 transition-colors disabled:opacity-30 disabled:hover:bg-transparent ${className}`}
  >
    <Icon size={size} strokeWidth={2} />
  </button>
);

const ExtensionBadge = () => (
  <div className="relative group cursor-pointer">
    <div className="absolute -top-1 -right-1 w-3 h-3 bg-[#e01a2e] rounded-full flex items-center justify-center text-[8px] font-bold text-white border border-[#2b2a33]">
      1
    </div>
    <ShieldCheck size={18} className="text-[#e01a2e]" />
    
    {/* Tooltip mimicking uBlock popup */}
    <div className="absolute top-full right-0 mt-2 w-48 bg-[#202023] border border-[#42414d] rounded shadow-xl p-3 hidden group-hover:block z-50">
      <div className="flex justify-between items-center mb-2 border-b border-gray-700 pb-2">
        <span className="font-bold text-xs text-white">uBlock Origin</span>
        <span className="text-[10px] text-gray-400">1.52.0</span>
      </div>
      <div className="space-y-2">
        <div className="flex items-center justify-between text-xs text-gray-300">
          <span>Requests blocked:</span>
          <span className="text-[#e01a2e] font-mono">14</span>
        </div>
        <div className="flex items-center justify-between text-xs text-gray-300">
          <span>Domains connected:</span>
          <span className="font-mono">1</span>
        </div>
        <div className="text-[10px] text-gray-500 mt-2">
          YouTube Ad-scripts neutralized via Embed API.
        </div>
      </div>
    </div>
  </div>
);

const URLBar = ({ url, setUrl, onNavigate }) => {
  const [isFocused, setIsFocused] = useState(false);
  const inputRef = useRef(null);

  const handleKeyDown = (e) => {
    if (e.key === 'Enter') {
      onNavigate(inputRef.current.value);
      inputRef.current.blur();
    }
  };

  return (
    <div className={`flex-1 flex items-center h-8 bg-[#1c1b22] border ${isFocused ? 'border-[#00ddff] ring-2 ring-[#00ddff]/20' : 'border-transparent'} rounded-[4px] px-2 transition-all mx-2`}>
      {url.includes('https') ? <Lock size={12} className="text-[#43b581] mr-2" /> : <Search size={12} className="text-gray-400 mr-2" />}
      <input 
        ref={inputRef}
        className="flex-1 bg-transparent text-white text-sm outline-none placeholder-gray-500 font-sans"
        defaultValue={url}
        placeholder="Paste YouTube URL (e.g. https://youtu.be/...)"
        onFocus={() => setIsFocused(true)}
        onBlur={() => setIsFocused(false)}
        onKeyDown={handleKeyDown}
      />
      <div className="flex items-center gap-2">
        <ExtensionBadge />
        <Star size={14} className="text-gray-400 hover:text-white cursor-pointer" />
      </div>
    </div>
  );
};

const BookmarkTile = ({ title, icon, color, onClick }) => (
  <button 
    onClick={onClick}
    className="flex flex-col items-center gap-3 p-4 rounded-lg hover:bg-[#38383d] transition-colors group w-32"
  >
    <div className={`w-12 h-12 rounded-lg flex items-center justify-center text-white text-xl font-bold shadow-lg group-hover:scale-105 transition-transform ${color}`}>
      {icon}
    </div>
    <span className="text-xs text-gray-300 text-center font-medium truncate w-full">{title}</span>
  </button>
);

// --- Main Application ---

export default function FocusFoxBrowser() {
  // State
  const [url, setUrl] = useState("");
  const [activeVideoId, setActiveVideoId] = useState(null);
  const [history, setHistory] = useState([]);
  const [historyIndex, setHistoryIndex] = useState(-1);
  const [origin, setOrigin] = useState("");

  useEffect(() => {
    // Get the current origin to pass to YouTube to fix Error 153
    if (typeof window !== 'undefined') {
      setOrigin(window.location.origin);
    }
  }, []);

  // Helper: Extract Video ID
  const extractVideoId = (input) => {
    if (!input) return null;
    // Expanded Regex to handle m.youtube.com and other variants better
    const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
    const match = input.match(regExp);
    return (match && match[2].length === 11) ? match[2] : null;
  };

  const navigateTo = (input) => {
    let newUrl = input;
    let videoId = extractVideoId(input);

    // If it's not a URL, treat as search (mock)
    if (!videoId && !input.startsWith('http')) {
       if(input.length === 11) {
         videoId = input; 
         newUrl = `https://www.youtube.com/watch?v=${input}`;
       } else {
         alert("FocusFox: Please paste a valid YouTube Link to activate the player.");
         return;
       }
    }

    if (videoId) {
      // Update History
      const newHistory = history.slice(0, historyIndex + 1);
      newHistory.push({ url: newUrl, videoId });
      setHistory(newHistory);
      setHistoryIndex(newHistory.length - 1);
      
      setUrl(newUrl);
      setActiveVideoId(videoId);
    }
  };

  const handleBack = () => {
    if (historyIndex > 0) {
      const newIndex = historyIndex - 1;
      setHistoryIndex(newIndex);
      setUrl(history[newIndex].url);
      setActiveVideoId(history[newIndex].videoId);
    } else {
      goHome();
    }
  };

  const handleForward = () => {
    if (historyIndex < history.length - 1) {
      const newIndex = historyIndex + 1;
      setHistoryIndex(newIndex);
      setUrl(history[newIndex].url);
      setActiveVideoId(history[newIndex].videoId);
    }
  };

  const goHome = () => {
    setHistoryIndex(-1);
    setUrl("");
    setActiveVideoId(null);
  };

  return (
    <div className="w-full h-screen bg-[#1c1b22] text-white flex flex-col font-sans overflow-hidden">
      
      {/* --- Window Controls / Tab Bar --- */}
      <div className="h-10 bg-[#101013] flex items-end px-2 gap-1 pt-2">
        <Tab title={activeVideoId ? "YouTube Player" : "New Tab"} active={true} onClose={goHome} />
        <div className="p-1 rounded hover:bg-[#2b2a33] ml-1 cursor-pointer text-gray-400">
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M8 3V13M3 8H13" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/></svg>
        </div>
      </div>

      {/* --- Navigation Toolbar --- */}
      <div className="h-10 bg-[#2b2a33] flex items-center px-2 border-b border-[#000000]">
        <div className="flex gap-1">
          <IconButton icon={ArrowLeft} onClick={handleBack} disabled={historyIndex < 0} />
          <IconButton icon={ArrowRight} onClick={handleForward} disabled={historyIndex >= history.length - 1} />
          <IconButton icon={RotateCw} onClick={() => {}} />
        </div>
        
        <IconButton icon={Home} className="ml-1" onClick={goHome} />

        <URLBar url={url} setUrl={setUrl} onNavigate={navigateTo} />
        
        <div className="flex gap-1 ml-1">
          <IconButton icon={Puzzle} />
          <IconButton icon={Menu} />
        </div>
      </div>

      {/* --- Bookmarks Bar --- */}
      <div className="h-7 bg-[#2b2a33] flex items-center px-3 gap-4 text-[11px] text-gray-300 border-b border-[#000000] overflow-x-auto no-scrollbar">
        <span className="hover:text-white cursor-pointer flex items-center gap-1 shrink-0"><Youtube size={12}/> YouTube Home</span>
        <span className="hover:text-white cursor-pointer shrink-0">Physics Galaxy</span>
        <span className="hover:text-white cursor-pointer shrink-0">Mohit Tyagi</span>
        <span className="hover:text-white cursor-pointer shrink-0">Eduniti</span>
        <span className="hover:text-white cursor-pointer shrink-0">JEE Nexus</span>
      </div>

      {/* --- Main Content Area --- */}
      <div className="flex-1 bg-[#2b2a33] relative overflow-hidden flex flex-col items-center justify-center">
        
        {activeVideoId ? (
          <div className="w-full h-full flex flex-col">
            {/* Video Container */}
            <div className="w-full h-full bg-black relative">
              {/* FIX: Added 'origin' param and 'referrerPolicy' to fix Error 153.
                  This ensures YouTube knows the request is coming from a valid nested context.
              */}
              <iframe 
                src={`https://www.youtube.com/embed/${activeVideoId}?autoplay=1&modestbranding=1&rel=0&origin=${origin}`}
                title="YouTube video player"
                className="w-full h-full absolute inset-0"
                referrerPolicy="strict-origin-when-cross-origin"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                allowFullScreen
              />
            </div>
          </div>
        ) : (
          /* New Tab Page */
          <div className="w-full max-w-4xl p-8 flex flex-col items-center animate-in fade-in zoom-in duration-300 overflow-y-auto">
            
            <div className="mb-8 relative">
              <div className="w-24 h-24 rounded-full bg-gradient-to-tr from-[#e66465] to-[#9198e5] flex items-center justify-center shadow-2xl blur-sm absolute top-0 left-0 opacity-50"></div>
              <div className="w-24 h-24 relative z-10">
                 <svg viewBox="0 0 100 100" fill="none">
                   <circle cx="50" cy="50" r="48" stroke="#ff9400" strokeWidth="4" className="opacity-20"/>
                   <path d="M50 15C30 15 15 30 15 50C15 70 30 85 50 85C70 85 85 70 85 50" stroke="#ff9400" strokeWidth="8" strokeLinecap="round" className="animate-[spin_3s_linear_infinite]"/>
                 </svg>
                 <div className="absolute inset-0 flex items-center justify-center">
                   <Youtube size={40} className="text-white drop-shadow-lg" />
                 </div>
              </div>
            </div>

            <h1 className="text-2xl font-semibold text-white mb-8">FocusFox: JEE Mode</h1>

            <div className="w-full max-w-xl mb-10 relative">
               <input 
                 type="text" 
                 placeholder="Paste a YouTube Link here..." 
                 className="w-full h-12 rounded-lg bg-[#42414d] border-none px-12 text-white placeholder-gray-400 shadow-lg focus:ring-2 focus:ring-[#00ddff]/50 transition-all outline-none"
                 onKeyDown={(e) => e.key === 'Enter' && navigateTo(e.target.value)}
               />
               <Search className="absolute left-4 top-3.5 text-gray-400" size={20} />
            </div>

            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <BookmarkTile 
                title="Mohit Tyagi" 
                icon="MT" 
                color="bg-blue-600" 
                onClick={() => navigateTo("https://www.youtube.com/watch?v=Kk8q-2eR9sU")} 
              />
              <BookmarkTile 
                title="Physics Galaxy" 
                icon="PG" 
                color="bg-purple-600" 
                onClick={() => navigateTo("https://www.youtube.com/watch?v=wb7hXfXh8k8")} 
              />
              <BookmarkTile 
                title="Eduniti" 
                icon="ED" 
                color="bg-orange-500" 
                onClick={() => navigateTo("https://www.youtube.com/watch?v=qJ8k4Ww1j5k")} 
              />
              <BookmarkTile 
                title="Lofi Study" 
                icon="♫" 
                color="bg-teal-600" 
                onClick={() => navigateTo("https://www.youtube.com/watch?v=jfKfPfyJRdk")} 
              />
            </div>

            {/* Debug Info for User */}
            <div className="mt-12 p-4 rounded bg-[#42414d]/30 border border-[#42414d] text-xs text-gray-400 max-w-lg text-center">
              <div className="flex items-center justify-center gap-2 mb-1 text-yellow-500 font-bold">
                <AlertTriangle size={14} />
                <span>Troubleshooting</span>
              </div>
               If video shows "Error 153", it means YouTube blocked the embed for this specific video or environment. 
               Try a different video or refresh.
            </div>

          </div>
        )}
      </div>
    </div>
  );
}



