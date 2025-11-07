// Web3 Multi-Language Playground - Landing Page Scripts

// Smooth scrolling for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Add animation on scroll
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe language cards
document.querySelectorAll('.language-card, .feature-card').forEach(card => {
    card.style.opacity = '0';
    card.style.transform = 'translateY(20px)';
    card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
    observer.observe(card);
});

// Add copy button to code block
const codeBlock = document.querySelector('.cta-code code');
if (codeBlock) {
    const copyButton = document.createElement('button');
    copyButton.textContent = '📋 Copy';
    copyButton.style.marginLeft = '10px';
    copyButton.style.background = 'rgba(255, 255, 255, 0.2)';
    copyButton.style.border = 'none';
    copyButton.style.color = 'white';
    copyButton.style.padding = '5px 15px';
    copyButton.style.borderRadius = '5px';
    copyButton.style.cursor = 'pointer';

    copyButton.addEventListener('click', () => {
        navigator.clipboard.writeText(codeBlock.textContent);
        copyButton.textContent = '✅ Copied!';
        setTimeout(() => {
            copyButton.textContent = '📋 Copy';
        }, 2000);
    });

    codeBlock.parentElement.appendChild(copyButton);
}

// Add dynamic stats counter
function animateCounter(element, target, duration = 2000) {
    let current = 0;
    const increment = target / (duration / 16);
    const timer = setInterval(() => {
        current += increment;
        if (current >= target) {
            current = target;
            clearInterval(timer);
        }
        element.textContent = Math.floor(current);
    }, 16);
}

// GitHub stars counter (placeholder - would fetch from API in production)
window.addEventListener('load', () => {
    console.log('🚀 Web3 Multi-Language Playground loaded!');
    console.log('📚 Explore 15+ programming languages for blockchain development');
});
