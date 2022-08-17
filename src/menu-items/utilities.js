// assets
import { IconList, IconTruckDelivery, IconMessage } from '@tabler/icons';

// constant
const icons = {
    IconList,
    IconTruckDelivery,
    IconMessage
};

// ==============================|| UTILITIES MENU ITEMS ||============================== //

const utilities = {
    id: 'utilities',
    title: 'Mes Produits',
    type: 'group',
    children: [
        {
            id: 'util-typography',
            title: 'Mes Produits',
            type: 'item',
            url: '/produits',
            icon: icons.IconList,
            breadcrumbs: false
        },
        {
            id: 'util-color',
            title: 'Mes Commandes',
            type: 'item',
            url: '/commandes',
            icon: icons.IconTruckDelivery,
            breadcrumbs: false
        },
        {
            id: 'util-shadow',
            title: 'Messagerie',
            type: 'item',
            url: '/messagerie',
            icon: icons.IconMessage,
            breadcrumbs: false
        }
    ]
};

export default utilities;
