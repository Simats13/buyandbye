import PropTypes from 'prop-types';
import { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';

// material-ui
import { useTheme } from '@mui/material/styles';
import { Box, Tab, Tabs } from '@mui/material';

// project imports
import Details from './Details';
import Invoice from './Invoice';
import Status from './Status';
import MainCard from 'ui-component/cards/MainCard';

// assets
import DescriptionTwoToneIcon from '@mui/icons-material/DescriptionTwoTone';
import LocalShippingTwoToneIcon from '@mui/icons-material/LocalShippingTwoTone';
import ReceiptTwoToneIcon from '@mui/icons-material/ReceiptTwoTone';

// tab content
function TabPanel({ children, value, index, ...other }) {
    return (
        <div role="tabpanel" hidden={value !== index} id={`simple-tabpanel-${index}`} aria-labelledby={`simple-tab-${index}`} {...other}>
            {value === index && <Box sx={{ p: 0 }}>{children}</Box>}
        </div>
    );
}

TabPanel.propTypes = {
    children: PropTypes.node,
    index: PropTypes.any.isRequired,
    value: PropTypes.any.isRequired
};

function a11yProps(index) {
    return {
        id: `simple-tab-${index}`,
        'aria-controls': `simple-tabpanel-${index}`
    };
}

// ==============================|| ORDER DETAILS ||============================== //

const OrderDetails = () => {
    const theme = useTheme();
    // const location = useLocation();
    // const { row } = location.state;
    // console.log(row);
    const location = useLocation();
    const data = location.state;
    console.log(data);
    // set selected tab
    const [value, setValue] = useState(0);
    const handleChange = (event, newValue) => {
        setValue(newValue);
    };

    return (
        <MainCard>
            <Tabs
                value={value}
                indicatorColor="primary"
                textColor="primary"
                onChange={handleChange}
                variant="scrollable"
                aria-label="simple tabs example"
                sx={{
                    '& a': {
                        minHeight: 'auto',
                        minWidth: 10,
                        px: 1,
                        py: 1.5,
                        mr: 2.25,
                        color: theme.palette.grey[600],
                        display: 'flex',
                        flexDirection: 'row',
                        alignItems: 'center',
                        justifyContent: 'center'
                    },
                    '& a.Mui-selected': {
                        color: theme.palette.primary.main
                    },
                    '& a > svg': {
                        marginBottom: '0px !important',
                        marginRight: 1.25
                    },
                    mb: 3
                }}
            >
                <Tab icon={<LocalShippingTwoToneIcon />} component={Link} to="#" label="Statut" state={data} {...a11yProps(0)} />
                <Tab icon={<DescriptionTwoToneIcon />} component={Link} to="#" label="Détails" state={data} {...a11yProps(2)} />
                <Tab icon={<ReceiptTwoToneIcon />} component={Link} to="#" label="Facture" state={data} {...a11yProps(1)} />
            </Tabs>

            {/* tab - status */}
            <TabPanel value={value} index={0}>
                <Status />
            </TabPanel>

            {/* tab - details */}
            <TabPanel value={value} index={2}>
                <Details />
            </TabPanel>

            {/* tab - invoice */}
            <TabPanel value={value} index={1}>
                <Invoice />
            </TabPanel>
        </MainCard>
    );
};

export default OrderDetails;
