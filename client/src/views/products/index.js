import PropTypes from 'prop-types';
import * as React from 'react';
import { Link } from 'react-router-dom';

// material-ui
import { useTheme } from '@mui/material/styles';
import {
    CardContent,
    Checkbox,
    Fab,
    Grid,
    IconButton,
    InputAdornment,
    Menu,
    MenuItem,
    Table,
    TableBody,
    TableCell,
    TableContainer,
    TableHead,
    TablePagination,
    TableRow,
    TableSortLabel,
    TextField,
    Toolbar,
    Tooltip,
    Typography
} from '@mui/material';

// third-party
import { format } from 'date-fns';

// project imports
import MainCard from 'ui-component/cards/MainCard';
import Avatar from 'ui-component/extended/Avatar';
import Chip from 'ui-component/extended/Chip';
import { useDispatch, useSelector } from 'store';
import { getProducts } from 'store/slices/product';

// assets
import DeleteIcon from '@mui/icons-material/Delete';
import FilterListIcon from '@mui/icons-material/FilterListTwoTone';
import PrintIcon from '@mui/icons-material/PrintTwoTone';
import FileCopyIcon from '@mui/icons-material/FileCopyTwoTone';
import SearchIcon from '@mui/icons-material/Search';
import AddIcon from '@mui/icons-material/AddTwoTone';
import MoreHorizOutlinedIcon from '@mui/icons-material/MoreHorizOutlined';
import { openSnackbar } from 'store/slices/snackbar';
import axios from 'utils/axios';
import useAuth from 'hooks/useAuth';
import ProductAdd from './ProductAdd';
import ProductEdit from './Edit';

const prodImage = require.context('assets/images/e-commerce', true);

// table sort
function descendingComparator(a, b, orderBy) {
    if (b[orderBy] < a[orderBy]) {
        return -1;
    }
    if (b[orderBy] > a[orderBy]) {
        return 1;
    }
    return 0;
}

const getComparator = (order, orderBy) =>
    order === 'desc' ? (a, b) => descendingComparator(a, b, orderBy) : (a, b) => -descendingComparator(a, b, orderBy);

function stableSort(array, comparator) {
    const stabilizedThis = array.map((el, index) => [el, index]);
    stabilizedThis.sort((a, b) => {
        const order = comparator(a[0], b[0]);
        if (order !== 0) return order;
        return a[1] - b[1];
    });
    return stabilizedThis.map((el) => el[0]);
}

// table header options
const headCells = [
    {
        id: 'id',
        numeric: true,
        label: '#',
        align: 'center'
    },
    {
        id: 'name',
        numeric: false,
        label: 'Nom du Produit',
        align: 'left'
    },
    {
        id: 'quantity',
        numeric: false,
        label: 'Quantité',
        align: 'left'
    },
    {
        id: 'price',
        numeric: true,
        label: 'Prix',
        align: 'right'
    },
    {
        id: 'status',
        numeric: true,
        label: 'Statut',
        align: 'center'
    }
];

// ==============================|| TABLE HEADER ||============================== //

function EnhancedTableHead({ onSelectAllClick, order, orderBy, numSelected, rowCount, onRequestSort, theme, selected }) {
    const createSortHandler = (property) => (event) => {
        onRequestSort(event, property);
    };

    return (
        <TableHead>
            <TableRow>
                <TableCell padding="checkbox" sx={{ pl: 3 }}>
                    <Checkbox
                        color="primary"
                        indeterminate={numSelected > 0 && numSelected < rowCount}
                        checked={rowCount > 0 && numSelected === rowCount}
                        onChange={onSelectAllClick}
                        inputProps={{
                            'aria-label': 'select all desserts'
                        }}
                    />
                </TableCell>
                {numSelected > 0 && (
                    <TableCell padding="none" colSpan={7}>
                        <EnhancedTableToolbar numSelected={selected.length} />
                    </TableCell>
                )}
                {numSelected <= 0 &&
                    headCells.map((headCell) => (
                        <TableCell
                            key={headCell.id}
                            align={headCell.align}
                            padding={headCell.disablePadding ? 'none' : 'normal'}
                            sortDirection={orderBy === headCell.id ? order : false}
                        >
                            <TableSortLabel
                                active={orderBy === headCell.id}
                                direction={orderBy === headCell.id ? order : 'asc'}
                                onClick={createSortHandler(headCell.id)}
                            >
                                {headCell.label}
                                {orderBy === headCell.id ? (
                                    <Typography component="span" sx={{ display: 'none' }}>
                                        {order === 'desc' ? 'sorted descending' : 'sorted ascending'}
                                    </Typography>
                                ) : null}
                            </TableSortLabel>
                        </TableCell>
                    ))}
                {numSelected <= 0 && (
                    <TableCell sortDirection={false} align="center" sx={{ pr: 3 }}>
                        <Typography
                            variant="subtitle1"
                            sx={{ color: theme.palette.mode === 'dark' ? theme.palette.grey[600] : 'grey.900' }}
                        >
                            Action
                        </Typography>
                    </TableCell>
                )}
            </TableRow>
        </TableHead>
    );
}

EnhancedTableHead.propTypes = {
    theme: PropTypes.object,
    selected: PropTypes.array,
    numSelected: PropTypes.number.isRequired,
    onRequestSort: PropTypes.func.isRequired,
    onSelectAllClick: PropTypes.func.isRequired,
    order: PropTypes.oneOf(['asc', 'desc']).isRequired,
    orderBy: PropTypes.string.isRequired,
    rowCount: PropTypes.number.isRequired
};

// ==============================|| TABLE HEADER TOOLBAR ||============================== //

const EnhancedTableToolbar = ({ numSelected }) => (
    <Toolbar
        sx={{
            p: 0,
            pl: 2,
            pr: 1,
            color: numSelected > 0 ? 'secondary.main' : 'inherit'
        }}
    >
        {numSelected > 0 ? (
            <Typography sx={{ flex: '1 1 100%' }} color="inherit" variant="h4" component="div">
                {numSelected} Selected
            </Typography>
        ) : (
            <Typography sx={{ flex: '1 1 100%' }} variant="h6" id="tableTitle" component="div">
                Nutrition
            </Typography>
        )}

        {numSelected > 0 && (
            <Tooltip title="Delete">
                <IconButton size="large">
                    <DeleteIcon fontSize="small" />
                </IconButton>
            </Tooltip>
        )}
    </Toolbar>
);

EnhancedTableToolbar.propTypes = {
    numSelected: PropTypes.number.isRequired
};

// ==============================|| PRODUCT LIST ||============================== //

const Product = () => {
    const theme = useTheme();
    const dispatch = useDispatch();

    const [order, setOrder] = React.useState('asc');
    const [orderBy, setOrderBy] = React.useState('calories');
    const [selected, setSelected] = React.useState([]);
    const [page, setPage] = React.useState(0);
    const [rowsPerPage, setRowsPerPage] = React.useState(5);
    const [search, setSearch] = React.useState('');
    const [rows, setRows] = React.useState([]);
    const { products } = useSelector((state) => state.product);
    const { user } = useAuth();
    const getData = async () => {
        const res = await axios.get(`/api/shops/${user.id}/products`).then((res, err) => {
            if (!res || err) {
                dispatch(openSnackbar('error', 'Error while fetching data'));
            }
            return res;
        });

        return res.data;
    };

    const [anchorEl, setAnchorEl] = React.useState(null);

    const handleMenuClick = (event) => {
        setAnchorEl(event?.currentTarget);
    };

    const handleClose = () => {
        setAnchorEl(null);
    };

    React.useEffect(() => {
        getData().then((res) => setRows(res));
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    console.log(rows);

    const handleSearch = (event) => {
        const newString = event?.target.value;
        setSearch(newString || '');

        if (newString) {
            const newRows = rows?.filter((row) => {
                let matches = true;

                const properties = ['name', 'visibility'];
                let containsQuery = false;

                properties.forEach((property) => {
                    if (row[property].toString().toLowerCase().includes(newString.toString().toLowerCase())) {
                        containsQuery = true;
                    }
                });

                if (!containsQuery) {
                    matches = false;
                }
                return matches;
            });
            setRows(newRows);
        } else {
            getProducts();
        }
    };

    // show a right sidebar when clicked on new product
    const [openAdd, setOpenAdd] = React.useState(false);
    const [openEdit, setOpenEdit] = React.useState(false);
    const handleClickOpenDialogAdd = () => {
        setOpenAdd(true);
    };
    const handleCloseDialogAdd = () => {
        setOpenAdd(false);
    };

    const handleClickOpenDialogEdit = () => {
        setOpenEdit(true);
    };
    const handleCloseDialogEdit = () => {
        setOpenEdit(false);
    };

    const handleRequestSort = (event, property) => {
        const isAsc = orderBy === property && order === 'asc';
        setOrder(isAsc ? 'desc' : 'asc');
        setOrderBy(property);
    };

    const handleSelectAllClick = (event) => {
        if (event.target.checked) {
            const newSelectedId = rows?.map((n) => n.name);
            setSelected(newSelectedId);
            return;
        }
        setSelected([]);
    };

    const handleClick = (event, name) => {
        const selectedIndex = selected.indexOf(name);
        let newSelected = [];

        if (selectedIndex === -1) {
            newSelected = newSelected.concat(selected, name);
        } else if (selectedIndex === 0) {
            newSelected = newSelected.concat(selected.slice(1));
        } else if (selectedIndex === selected.length - 1) {
            newSelected = newSelected.concat(selected.slice(0, -1));
        } else if (selectedIndex > 0) {
            newSelected = newSelected.concat(selected.slice(0, selectedIndex), selected.slice(selectedIndex + 1));
        }

        setSelected(newSelected);
    };

    const handleChangePage = (event, newPage) => {
        setPage(newPage);
    };

    const handleChangeRowsPerPage = (event) => {
        setRowsPerPage(parseInt(event?.target.value, 10));
        setPage(0);
    };

    const isSelected = (name) => selected.indexOf(name) !== -1;
    const emptyRows = page > 0 ? Math.max(0, (1 + page) * rowsPerPage - rows.length) : 0;

    return (
        <MainCard title="Liste des produits" content={false}>
            <CardContent>
                <Grid container justifyContent="space-between" alignItems="center" spacing={2}>
                    <Grid item xs={12} sm={6}>
                        <TextField
                            InputProps={{
                                startAdornment: (
                                    <InputAdornment position="start">
                                        <SearchIcon fontSize="small" />
                                    </InputAdornment>
                                )
                            }}
                            onChange={handleSearch}
                            placeholder="Chercher un produit"
                            value={search}
                            size="small"
                        />
                    </Grid>
                    <Grid item xs={12} sm={6} sx={{ textAlign: 'right' }}>
                        <Tooltip title="Copy">
                            <IconButton size="large">
                                <FileCopyIcon />
                            </IconButton>
                        </Tooltip>
                        <Tooltip title="Print">
                            <IconButton size="large">
                                <PrintIcon />
                            </IconButton>
                        </Tooltip>
                        <Tooltip title="Filter">
                            <IconButton size="large">
                                <FilterListIcon />
                            </IconButton>
                        </Tooltip>

                        <Tooltip title="Ajouter un Produit">
                            <Fab
                                color="primary"
                                size="small"
                                onClick={handleClickOpenDialogAdd}
                                sx={{ boxShadow: 'none', ml: 1, width: 32, height: 32, minHeight: 32 }}
                            >
                                <AddIcon fontSize="small" />
                            </Fab>
                        </Tooltip>
                        <ProductAdd open={openAdd} handleCloseDialog={handleCloseDialogAdd} />
                    </Grid>
                </Grid>
            </CardContent>

            {/* table */}
            <TableContainer>
                <Table sx={{ minWidth: 750 }} aria-labelledby="tableTitle">
                    <EnhancedTableHead
                        numSelected={selected.length}
                        order={order}
                        orderBy={orderBy}
                        onSelectAllClick={handleSelectAllClick}
                        onRequestSort={handleRequestSort}
                        rowCount={rows.length}
                        theme={theme}
                        selected={selected}
                    />
                    <TableBody>
                        {stableSort(rows, getComparator(order, orderBy))
                            .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
                            .map((row, index) => {
                                if (typeof row === 'number') return null;
                                const isItemSelected = isSelected(row.name);
                                const labelId = `enhanced-table-checkbox-${index}`;
                                return (
                                    <TableRow
                                        hover
                                        role="checkbox"
                                        aria-checked={isItemSelected}
                                        tabIndex={-1}
                                        key={index}
                                        selected={isItemSelected}
                                    >
                                        <TableCell padding="checkbox" sx={{ pl: 3 }} onClick={(event) => handleClick(event, row.name)}>
                                            <Checkbox
                                                color="primary"
                                                checked={isItemSelected}
                                                inputProps={{
                                                    'aria-labelledby': labelId
                                                }}
                                            />
                                        </TableCell>
                                        <TableCell
                                            align="center"
                                            component="th"
                                            id={labelId}
                                            scope="row"
                                            onClick={(event) => handleClick(event, row.name)}
                                            sx={{ cursor: 'pointer' }}
                                        >
                                            <Avatar src={row.image} size="md" variant="rounded" />
                                        </TableCell>
                                        <TableCell component="th" id={labelId} scope="row" sx={{ cursor: 'pointer' }}>
                                            <Typography
                                                component={Link}
                                                to={`/e-commerce/product-details/${row.id}`}
                                                variant="subtitle1"
                                                sx={{
                                                    color: theme.palette.mode === 'dark' ? theme.palette.grey[600] : 'grey.900',
                                                    textDecoration: 'none'
                                                }}
                                            >
                                                {row.name}
                                            </Typography>
                                        </TableCell>
                                        <TableCell align="left">{row.quantity}</TableCell>
                                        <TableCell align="right">{row.price} €</TableCell>
                                        {/* <TableCell align="right">${row.salePrice}</TableCell> */}
                                        <TableCell align="center">
                                            <Chip
                                                size="small"
                                                label={row.visibility ? 'Visible' : 'Masqué'}
                                                chipcolor={row.visibility ? 'success' : 'error'}
                                                sx={{ borderRadius: '4px', textTransform: 'capitalize' }}
                                            />
                                        </TableCell>
                                        <TableCell align="center" sx={{ pr: 3 }}>
                                            <IconButton onClick={handleMenuClick} size="large">
                                                <MoreHorizOutlinedIcon
                                                    fontSize="small"
                                                    aria-controls="menu-popular-card-1"
                                                    aria-haspopup="true"
                                                    sx={{ color: 'grey.500' }}
                                                />
                                            </IconButton>
                                            <Menu
                                                id="menu-popular-card-1"
                                                anchorEl={anchorEl}
                                                keepMounted
                                                open={Boolean(anchorEl)}
                                                onClose={handleClose}
                                                variant="selectedMenu"
                                                anchorOrigin={{
                                                    vertical: 'bottom',
                                                    horizontal: 'right'
                                                }}
                                                transformOrigin={{
                                                    vertical: 'top',
                                                    horizontal: 'right'
                                                }}
                                                sx={{
                                                    '& .MuiMenu-paper': {
                                                        boxShadow: theme.customShadows.z1
                                                    }
                                                }}
                                            >
                                                <MenuItem onClick={handleClickOpenDialogEdit} value={row.id}>
                                                    Editer
                                                </MenuItem>
                                                <ProductEdit open={openEdit} handleCloseDialog={handleCloseDialogEdit} />
                                                <MenuItem onClick={handleClose}> Supprimer</MenuItem>
                                            </Menu>
                                        </TableCell>
                                    </TableRow>
                                );
                            })}
                        {emptyRows > 0 && (
                            <TableRow
                                style={{
                                    height: 53 * emptyRows
                                }}
                            >
                                <TableCell colSpan={6} />
                            </TableRow>
                        )}
                    </TableBody>
                </Table>
            </TableContainer>

            {/* table pagination */}
            <TablePagination
                rowsPerPageOptions={[5, 10, 25]}
                component="div"
                count={rows.length}
                rowsPerPage={rowsPerPage}
                page={page}
                onPageChange={handleChangePage}
                onRowsPerPageChange={handleChangeRowsPerPage}
            />
        </MainCard>
    );
};

export default Product;
