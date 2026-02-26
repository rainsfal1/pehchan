// Intersection Observer for scroll animations
const observerOptions = {
    root: null,
    rootMargin: '0px',
    threshold: 0.15
};

const observer = new IntersectionObserver((entries, observer) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('in-view');
            observer.unobserve(entry.target);
        }
    });
}, observerOptions);

document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.fade-up, .fade-left, .fade-right').forEach(el => {
        observer.observe(el);
    });

    updateSlideshow();

    const speedInput = document.getElementById('speech-speed');
    const speedDisplay = document.getElementById('speed-display');

    if (speedInput && speedDisplay) {
        const updateSpeedLabel = (value) => {
            speedDisplay.textContent = `${parseFloat(value).toFixed(1)}x`;
        };

        updateSpeedLabel(speedInput.value);

        speedInput.addEventListener('input', (e) => {
            updateSpeedLabel(e.target.value);
        });
    }

    if (window.lucide && typeof window.lucide.createIcons === 'function') {
        window.lucide.createIcons();
    }

    startAutoSlide();
});

// Cursor gradient effect
document.addEventListener('mousemove', (e) => {
    const x = e.clientX;
    const y = e.clientY;

    document.documentElement.style.setProperty('--cursor-x', `${x}px`);
    document.documentElement.style.setProperty('--cursor-y', `${y}px`);
});

// ----------------------------------------------------------------------
// INTERACTIVE SETTINGS LOGIC
// ----------------------------------------------------------------------

// 1. Slideshow Navigation
let currentSlide = 0;
const totalSlides = 3;
let autoSlideTimer = null;
const AUTO_SLIDE_INTERVAL_MS = 6000;

function updateSlideshow() {
    const track = document.getElementById('settings-track');
    const prevBtn = document.querySelector('.slide-prev');
    const nextBtn = document.querySelector('.slide-next');

    if (track) {
        const isRTL = document.body.getAttribute('dir') === 'rtl';
        const direction = isRTL ? '+' : '-';
        track.style.transform = `translateX(${direction}${currentSlide * 100}%)`;
    }

    if (prevBtn) {
        prevBtn.style.opacity = currentSlide === 0 ? '0.3' : '1';
        prevBtn.style.pointerEvents = currentSlide === 0 ? 'none' : 'auto';
    }
    if (nextBtn) {
        nextBtn.style.opacity = currentSlide === totalSlides - 1 ? '0.3' : '1';
        nextBtn.style.pointerEvents = currentSlide === totalSlides - 1 ? 'none' : 'auto';
    }
}

function stopAutoSlide() {
    if (autoSlideTimer !== null) {
        clearInterval(autoSlideTimer);
        autoSlideTimer = null;
    }
}

function startAutoSlide() {
    stopAutoSlide();
    autoSlideTimer = setInterval(() => {
        changeSlide(1, false);
    }, AUTO_SLIDE_INTERVAL_MS);
}

function changeSlide(direction, isManual = true) {
    if (isManual) {
        stopAutoSlide();
    }
    currentSlide = (currentSlide + direction + totalSlides) % totalSlides;
    updateSlideshow();
}

function goToSlide(index, isManual = true) {
    if (isManual) {
        stopAutoSlide();
    }
    currentSlide = index;
    updateSlideshow();
}

// 2. Theme Switcher
function setTheme(theme) {
    // Remove existing theme classes
    document.body.classList.remove('theme-black', 'theme-white', 'theme-blue');

    // Add new theme class if not default black
    if (theme !== 'black') {
        document.body.classList.add(`theme-${theme}`);
    }

    // Update button states
    document.querySelectorAll('.theme-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelector(`.theme-${theme}`).classList.add('active');
}

// 3. Screen Reader Testing
function testAudio() {
    if (!('speechSynthesis' in window)) {
        alert("Sorry, your browser doesn't support text to speech!");
        return;
    }

    // Cancel any ongoing speech
    window.speechSynthesis.cancel();

    // Get current language context
    const isUrdu = document.getElementById('lang-ur').classList.contains('active');

    const textToSpeak = isUrdu
        ? "پہچان میں خوش آمدید۔ آپ کی ادویات محفوظ ہیں۔"
        : "Welcome to Pehchan. Your medication is safe.";

    const utterance = new SpeechSynthesisUtterance(textToSpeak);

    // Set speed from slider
    const speed = parseFloat(document.getElementById('speech-speed').value);
    utterance.rate = speed;

    // Try to set language
    utterance.lang = isUrdu ? 'ur-PK' : 'en-US';

    window.speechSynthesis.speak(utterance);
}

// 4. Language Translations (English / Urdu)
const translations = {
    'en': {
        'logo': 'PEHCHAN.',
        'header_drap': 'DRAP',
        'header_source': 'SOURCE',
        'hero_title': 'ACCESSIBLE<br><span class="text-gray">PARENTING.</span>',
        'hero_desc': 'Reducing the risks of giving wrong or expired medication. Audio guidance for educated choices. Empowering blind and visually impaired parents with true independence.',
        'discover_btn': 'DISCOVER FEATURES',
        'instant_title': 'INSTANT<br>RECOGNITION.',
        'instant_desc': 'Point your camera. Our integrated Google ML Kit identifies the package and reads aloud the medication name, usage, precautions, and flags any registered childhood allergies.',
        'settings_title': 'CUSTOMIZED<br>SETTINGS.',
        'settings_desc': 'Tailor the app to your specific visibility contour colors and proactively register your child\'s allergies for AI-driven safety warnings.',
        'timely_title': 'TIMELY<br>PRESCRIPTIONS.',
        'timely_desc': 'Never miss a dose. Scanning pharmacy labels instantly translates printed schedules into scheduled morning, afternoon, or evening audio reminders.',
        'remaining_title': 'REMAINING<br>LIQUID.',
        'remaining_desc': 'Double-check your poured amount or track inventory for future usage. Pehchan precisely calculates and aurally reports how much liquid medication remains in a container.',
        'audio_title': 'AUDIO<br>DOSAGE.',
        'audio_desc': 'Adjust a digital slider, and start pouring. Our on-device, edge-deployed YOLO model (TensorFlow Lite) tracks the liquid level in real-time, guiding your pour with precise audio tones.',
        'slide_theme_title': 'VISIBILITY THEME',
        'slide_audio_title': 'AUDIO CUES',
        'slide_speed_label': 'SPEED',
        'slide_test_btn': 'TEST AUDIO',
        'slide_lang_title': 'SYSTEM LANGUAGE',
        'nav_theme': 'THEME',
        'nav_audio': 'AUDIO',
        'nav_language': 'LANGUAGE',
        'ui_pill_detected': 'MEDICATION DETECTED',
        'ui_slider_pouring': 'POURING 4.5mL / 5.0mL',
        'spec_stack_title': 'STACK',
        'spec_impact_title': 'IMPACT',
        'spec_impact_sdg3': 'SDG 3: Good Health',
        'spec_impact_sdg4': 'SDG 4: Quality Tech Ed',
        'spec_impact_sdg10': 'SDG 10: Reduced Inequalities',
        'spec_accessibility_title': 'ACCESSIBILITY',
        'spec_accessibility_voice': 'Voice Guidance',
        'spec_accessibility_offline': 'Offline-First',
        'spec_accessibility_haptic': 'Haptic Feedback',
        'footer_title': 'EXPLORE<br>THE ARCHITECTURE.',
        'footer_github': 'GITHUB REPOSITORY',
        'footer_copyright': '© 2025 Rainsfal. Designed for purpose.'
    },
    'ur': {
        'logo': 'پہچان',
        'header_drap': 'ڈریپ',
        'header_source': 'سورس کوڈ',
        'hero_title': 'قابل رسائی<br><span class="text-gray">والدینیت</span>',
        'hero_desc': 'غلط یا میعاد ختہ ادویات دینے کے خطرات کو کم کرنا۔ باخبر فیصلوں کے لیے آڈیو رہنمائی۔ نابینا اور بصارت سے محروم والدین کو حقیقی آزادی کے ساتھ بااختیار بنانا۔',
        'discover_btn': 'خصوصیات دریافت کریں',
        'instant_title': 'فوری<br>شناخت',
        'instant_desc': 'اپنے کیمرے کی طرف اشارہ کریں۔ ہمارا گوگل ایم ایل کٹ پیکیج کی شناخت کرکے دوا کا نام، استعمال، احتیاطی تدابیر بلند آواز میں پڑھتا ہے اور رجسٹرڈ بچپن کی الرجی کی نشاندہی کرتا ہے۔',
        'settings_title': 'حسب ضرورت<br>ترتیبات',
        'settings_desc': 'اپنی مخصوص بصری ضروریات کے مطابق ایپ کو ترتیب دیں اور اے آئی سے چلنے والے حفاظتی انتباہات کے لیے اپنے بچے کی الرجی کا اندراج کریں۔',
        'timely_title': 'بروقت<br>نسخے',
        'timely_desc': 'کبھی خوراک نہ چھوڑیں۔ فارمیسی لیبلز کو اسکین کرنا فوری طور پر شیڈول کو صبح، دوپہر یا شام کی آڈیو یاددہانیوں میں تبدیل کرتا ہے۔',
        'remaining_title': 'باقی<br>مائع',
        'remaining_desc': 'اپنی ڈالی گئی مقدار کو دوبارہ چیک کریں یا مستقبل کے استعمال کے لیے انوینٹری ٹریک کریں۔ پہچان درست طریقے سے حساب لگاتا ہے اور آواز میں رپورٹ کرتا ہے کہ کنٹینر میں کتنی مائع دوا باقی ہے۔',
        'audio_title': 'آڈیو<br>خوراک',
        'audio_desc': 'ڈیجیٹل سلائیڈر کو ایڈجسٹ کریں اور ڈالنا شروع کریں۔ ہمارا ڈیوائس پر موجود YOLO ماڈل ریئل ٹائم میں مائع کی سطح ٹریک کرتا ہے اور درست آڈیو ٹونز سے آپ کی رہنمائی کرتا ہے۔',
        'slide_theme_title': 'بصری تھیم',
        'slide_audio_title': 'آڈیو اشارے',
        'slide_speed_label': 'رفتار',
        'slide_test_btn': 'آڈیو ٹیسٹ کریں',
        'slide_lang_title': 'سسٹم زبان',
        'nav_theme': 'تھیم',
        'nav_audio': 'آڈیو',
        'nav_language': 'زبان',
        'ui_pill_detected': 'دوا شناخت ہوگئی',
        'ui_slider_pouring': '4.5mL / 5.0mL ڈالا جا رہا ہے',
        'spec_stack_title': 'ٹیکنالوجی',
        'spec_impact_title': 'اثرات',
        'spec_impact_sdg3': 'SDG 3: اچھی صحت',
        'spec_impact_sdg4': 'SDG 4: معیاری تعلیم',
        'spec_impact_sdg10': 'SDG 10: عدم مساوات میں کمی',
        'spec_accessibility_title': 'رسائی',
        'spec_accessibility_voice': 'آواز کی رہنمائی',
        'spec_accessibility_offline': 'آف لائن موڈ',
        'spec_accessibility_haptic': 'ہیپٹک فیڈبیک',
        'footer_title': 'تلاش کریں<br>فن تعمیر',
        'footer_github': 'گِٹ ہب ریپوزٹری',
        'footer_copyright': '© 2025 رینزفال۔ مقصد کے لیے ڈیزائن کیا گیا۔'
    }
};

function setLanguage(lang) {
    document.querySelectorAll('.lang-btn').forEach(btn => btn.classList.remove('active'));
    document.getElementById(`lang-${lang}`).classList.add('active');

    if (lang === 'ur') {
        document.body.setAttribute('dir', 'rtl');
        document.body.classList.add('urdu-mode');
        document.documentElement.setAttribute('lang', 'ur');
    } else {
        document.body.setAttribute('dir', 'ltr');
        document.body.classList.remove('urdu-mode');
        document.documentElement.setAttribute('lang', 'en');
    }

    const elements = document.querySelectorAll('[data-i18n]');
    elements.forEach(el => {
        if (el.hasAttribute('data-no-translate')) {
            return;
        }
        const key = el.getAttribute('data-i18n');
        if (translations[lang][key]) {
            el.innerHTML = translations[lang][key];
        }
    });

    updateSlideshow();

    if (window.lucide && typeof window.lucide.createIcons === 'function') {
        window.lucide.createIcons();
    }
}
