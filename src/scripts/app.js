import React from 'react';
import ReactDOM from 'react-dom';
import ProxesComponents from 'react-proxes-components/react-proxes-components';

ReactDOM.render(
    <ProxesComponents autoPoll="true" pollInterval="200000"/>,
    document.getElementById('indexlist')
);
