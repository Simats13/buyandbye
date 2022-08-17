// assets
import { IconBuildingStore } from '@tabler/icons';

// constant
const icons = { IconBuildingStore };

// ==============================|| DASHBOARD MENU ITEMS ||============================== //

const enterprise = {
    id: 'enterprise',
    title: 'Mon Entreprise',
    type: 'group',
    children: [
        {
            id: 'enterprise',
            title: "Gestion de l'entreprise",
            type: 'item',
            url: '/entreprise',
            icon: icons.IconBuildingStore,
            breadcrumbs: false
        }
    ]
};

export default enterprise;
