import React from 'react';
import ReactDOM from 'react-dom';
import ProxesComponents from 'react-proxes-components/react-proxes-components';

var elasticsearch_url = document.getElementById('react-dashboard').getAttribute('data-elasticsearch-url');
ReactDOM.render(<ProxesComponents pollInterval="30000" elasticsearch_url={elasticsearch_url}/>, document.getElementById('react-dashboard'));

// ReactDOM.render(
//     <Health store={new ESStore()}/>,
//     document.getElementById('indexlist')
// );
