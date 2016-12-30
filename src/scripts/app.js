import React from 'react';
import ReactDOM from 'react-dom';
import ProxesComponents from 'react-proxes-components/react-proxes-components';

ReactDOM.render(<ProxesComponents pollInterval="30000"/>, document.getElementById('react-dashboard'));

// ReactDOM.render(
//     <Health store={new ESStore()}/>,
//     document.getElementById('indexlist')
// );
