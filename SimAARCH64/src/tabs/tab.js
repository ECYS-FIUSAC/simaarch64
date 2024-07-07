let tabCount = 0;

function addNewTab(fileName = 'Untitled', fileContent = '') {
    const tabId = `tab-${tabCount}`;
    const contentId = `content-${tabCount}`;

    const tab = document.createElement('div');
    tab.className = 'tab';
    tab.id = tabId;
    if(fileName === 'Untitled'){
        fileName = `${fileName} ${tabCount+1}`;
    }
    tab.innerHTML = `${fileName} <span class="close-btn" onclick="closeTab('${tabId}', '${contentId}')">&times;</span>`;
    tab.onclick = () => activateTab(tabId, contentId);
    
    const content = document.createElement('div');
    content.className = 'tab-content';
    content.id = contentId;

    const textarea = document.createElement('textarea');
    content.appendChild(textarea);

    document.querySelector('.tabs').insertBefore(tab, document.querySelector('.add-tab'));
    document.querySelector('.tab-contents').appendChild(content);

    const editor = CodeMirror.fromTextArea(textarea, {
            lineNumbers: true,
            mode: { name: "gas", architecture: "ARM" },
            theme: "dracula",
            viewportMargin: Infinity,
    });
    textarea.value = fileContent;
    editor.setValue(fileContent);
    setTimeout(() => {
        editor.refresh();
    }, 1);
    activateTab(tabId, contentId);

    tabCount++;
}

function activateTab(tabId, contentId) {
    document.querySelectorAll('.tab').forEach(tab => {
        tab.classList.remove('active');
    });
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });

    document.getElementById(tabId).classList.add('active');
    document.getElementById(contentId).classList.add('active');
}

function closeTab(tabId, contentId) {
    const tab = document.getElementById(tabId);
    const content = document.getElementById(contentId);
    
    if (tab.classList.contains('active')) {
        const nextTab = tab.nextElementSibling || tab.previousElementSibling;
        if (nextTab && nextTab.classList.contains('tab')) {
            const nextContentId = nextTab.id.replace('tab', 'content');
            activateTab(nextTab.id, nextContentId);
        }
    }

    tab.remove();
    content.remove();
}


function openFile(event) {
    const file = event.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = function(e) {
        addNewTab(file.name, e.target.result);
    };
    reader.readAsText(file);
}

function saveFile() {
    const activeContent = document.querySelector('.tab-content.active');
    if (!activeContent) return; // Si no hay ninguna pestaña activa, no hacemos nada

    const editor = activeContent.querySelector('.CodeMirror').CodeMirror;
    const content = editor.getValue();

    const blob = new Blob([content], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);

    const a = document.createElement('a');
    a.href = url;
    const activeTab = document.querySelector('.tab.active');
    let fileName = activeTab.textContent.trim().replace('×', '');
    fileName = fileName.trim()+'.s';
    a.download = fileName;
    a.click();
}

function cleanEditor(){
    const activeContent = document.querySelector('.tab-content.active');
    if (!activeContent) return; // Si no hay ninguna pestaña activa, no hacemos nada

    const editor = activeContent.querySelector('.CodeMirror').CodeMirror;
    editor.setValue('');
}

document.addEventListener('keydown', function(event) {
    if (event.ctrlKey && event.key === 'o') {
        event.preventDefault();
        document.getElementById('file-input').click();
    }
});

function printCode() {
    const activeContent = document.querySelector('.tab-content.active');
    if (!activeContent) return; // Si no hay ninguna pestaña activa, no hacemos nada

    const editor = activeContent.querySelector('.CodeMirror').CodeMirror;
    const content = editor.getValue();
}

/* Tabs Resultas */

function openTab(tabName, buttonId) {
        var i, tabcontent, tablinks;
        tabcontent = document.getElementsByClassName("tab-result");
        for (i = 0; i < tabcontent.length; i++) {
            tabcontent[i].style.display = "none";
        }
        document.getElementById(tabName).style.display = "block";

        // Quita la clase 'active-tab' de todos los botones
        var tabBtns = document.getElementsByClassName("tab-btn-result");
        for (i = 0; i < tabBtns.length; i++) {
            tabBtns[i].classList.remove("active-tab-result");
        }
        // Agrega la clase 'active-tab' al botón actual
        document.getElementById(buttonId).classList.add("active-tab-result");
    }