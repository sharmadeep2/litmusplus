// Litmus++ Dynamic Branding Script
// This script runs after the React app loads and replaces Litmus branding with Litmus++

(function() {
    'use strict';
    
    console.log('Litmus++ Branding Enhancement: Starting...');
    
    function replaceLitmusText() {
        // Function to replace text content in DOM elements
        function replaceTextInElement(element, searchText, replaceText) {
            if (element.nodeType === 3) { // Text node
                if (element.nodeValue.includes(searchText)) {
                    element.nodeValue = element.nodeValue.replace(new RegExp(searchText, 'g'), replaceText);
                    return true;
                }
            } else if (element.nodeType === 1) { // Element node
                let replaced = false;
                for (let child of element.childNodes) {
                    if (replaceTextInElement(child, searchText, replaceText)) {
                        replaced = true;
                    }
                }
                return replaced;
            }
            return false;
        }
        
        // Replace all instances of "Litmus 3.0" with "Litmus++ 3.0"
        replaceTextInElement(document.body, 'Litmus 3.0', 'Litmus++ 3.0');
        replaceTextInElement(document.body, 'Litmus 3', 'Litmus++ 3');
        
        // Replace instances of just "Litmus" with "Litmus++" (but be careful not to replace in URLs or technical terms)
        const textWalker = document.createTreeWalker(
            document.body,
            NodeFilter.SHOW_TEXT,
            null,
            false
        );
        
        let textNode;
        const nodesToUpdate = [];
        
        while (textNode = textWalker.nextNode()) {
            if (textNode.nodeValue.match(/^Litmus$/gi) || 
                textNode.nodeValue.match(/^Litmus\s/gi) ||
                textNode.nodeValue.trim() === 'Litmus') {
                nodesToUpdate.push({
                    node: textNode,
                    newValue: textNode.nodeValue.replace(/Litmus/gi, 'Litmus++')
                });
            }
        }
        
        // Apply the updates
        nodesToUpdate.forEach(update => {
            update.node.nodeValue = update.newValue;
        });
        
        // Also update any aria-labels or titles
        document.querySelectorAll('[aria-label*="Litmus"]').forEach(el => {
            el.setAttribute('aria-label', el.getAttribute('aria-label').replace(/Litmus/g, 'Litmus++'));
        });
        
        document.querySelectorAll('[title*="Litmus"]').forEach(el => {
            el.setAttribute('title', el.getAttribute('title').replace(/Litmus/g, 'Litmus++'));
        });
        
        console.log('Litmus++ Branding Enhancement: Text replacements completed');
    }
    
    // Run the replacement function
    function initBrandingReplacement() {
        // Wait for React to render content
        if (document.querySelector('#react-root') && document.querySelector('#react-root').innerHTML.trim() !== '') {
            replaceLitmusText();
            
            // Set up a MutationObserver to handle dynamic content
            const observer = new MutationObserver(function(mutations) {
                let shouldReplace = false;
                mutations.forEach(function(mutation) {
                    if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
                        shouldReplace = true;
                    }
                });
                
                if (shouldReplace) {
                    setTimeout(replaceLitmusText, 100); // Small delay to let React finish rendering
                }
            });
            
            observer.observe(document.body, {
                childList: true,
                subtree: true
            });
            
            console.log('Litmus++ Branding Enhancement: Observer set up for dynamic content');
        } else {
            // React not ready yet, try again in 500ms
            setTimeout(initBrandingReplacement, 500);
        }
    }
    
    // Start the process when the document is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initBrandingReplacement);
    } else {
        initBrandingReplacement();
    }
    
    console.log('Litmus++ Branding Enhancement: Initialized');
})();