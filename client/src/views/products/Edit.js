import PropTypes from 'prop-types';
import { forwardRef, useEffect, useRef, useState } from 'react';

// material-ui
import { useTheme, styled } from '@mui/material/styles';
import {
    Button,
    CardMedia,
    Chip,
    CircularProgress,
    Dialog,
    DialogActions,
    DialogContent,
    DialogTitle,
    Fab,
    Grid,
    Input,
    InputAdornment,
    InputLabel,
    MenuItem,
    Select,
    Slide,
    TextField,
    Typography
} from '@mui/material';

import * as yup from 'yup';
// project imports
import { gridSpacing } from 'store/constant';
import AnimateButton from 'ui-component/extended/AnimateButton';

// assets
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import CloseIcon from '@mui/icons-material/Close';
import { Form, Formik, useFormik } from 'formik';
import { dispatch } from 'store';

// styles
const ImageWrapper = styled('div')(({ theme }) => ({
    position: 'relative',
    overflow: 'hidden',
    borderRadius: '4px',
    cursor: 'pointer',
    width: 55,
    height: 55,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    background: theme.palette.background.default,
    '& > svg': {
        verticalAlign: 'sub',
        marginRight: 6
    }
}));

// animation
const Transition = forwardRef((props, ref) => <Slide direction="left" ref={ref} {...props} />);

const ITEM_HEIGHT = 48;
const ITEM_PADDING_TOP = 8;
const MenuProps = {
    PaperProps: {
        style: {
            maxHeight: ITEM_HEIGHT * 4.5 + ITEM_PADDING_TOP,
            width: 250
        }
    },
    chip: {
        margin: 2
    }
};

// tags list & style
const tagNames = ['Html', 'Scss', 'Js', 'React', 'Ionic', 'Angular', 'css', 'Php', 'View'];

function getStyles(name, personName, theme) {
    return {
        fontWeight: personName.indexOf(name) === -1 ? theme.typography.fontWeightRegular : theme.typography.fontWeightMedium
    };
}

// ==============================|| PRODUCT ADD DIALOG ||============================== //

const ProductEdit = ({ open, handleCloseDialog, data, tags }) => {
    const theme = useTheme();
    // handle category change dropdown
    const [currency, setCurrency] = useState('2');

    useEffect(() => {
        setCurrency(data.category || []);
    }, [data.category]);
    const handleSelectChange = (event) => {
        setCurrency(event?.target.value);
    };
    // set image upload progress
    const [progress, setProgress] = useState(0);
    const progressRef = useRef(() => {});
    useEffect(() => {
        progressRef.current = () => {
            if (progress > 100) {
                setProgress(0);
            } else {
                const diff = Math.random() * 10;
                setProgress(progress + diff);
            }
        };
    });

    useEffect(() => {
        const timer = setInterval(() => {
            progressRef.current();
        }, 500);

        return () => {
            clearInterval(timer);
        };
    }, []);

    // handle tag select
    const [personName, setPersonName] = useState([]);
    const handleTagSelectChange = (event) => {
        setPersonName(event?.target.value);
    };

    const validationSchema = yup.object({
        productName: yup.string().required('Product name is required'),
        productDescription: yup.string().required('Product description is required'),
        productPrice: yup.number().required('Product price is required'),
        productCategory: yup.string().required('Product category is required'),
        productReference: yup.string().required('Product reference is required'),
        productDiscount: yup.number().required('Product discount is required'),
        productQuantity: yup.number().required('Product quantity is required'),
        productBrand: yup.string().required('Product brand is required'),
        productWeight: yup.number().required('Product weight is required')
    });

    const formik = useFormik({
        // validationSchema,
        initialValues: {
            productName: data.name || '',
            productDescription: data.description || '',
            productCategory: currency || '',
            productReference: data.reference || 0,
            productPrice: data.price || 0,
            productDiscount: data.discount || 0,
            productQuantity: data.quantity || 0,
            productBrand: data.brand || '',
            productWeight: data.weight || 0
        },
        enableReinitialize: true,
        onSubmit: () => {
            console.log(formik.values);
        }
    });

    return (
        <Dialog
            open={open}
            TransitionComponent={Transition}
            keepMounted
            onClose={handleCloseDialog}
            sx={{
                '&>div:nth-of-type(3)': {
                    justifyContent: 'flex-end',
                    '&>div': {
                        m: 0,
                        borderRadius: '0px',
                        maxWidth: 450,
                        maxHeight: '100%'
                    }
                }
            }}
        >
            {open && (
                <>
                    <form onSubmit={formik.handleSubmit}>
                        <DialogTitle>Editer un Produit</DialogTitle>
                        <DialogContent>
                            <Grid container spacing={gridSpacing} sx={{ mt: 0.25 }}>
                                <Grid item xs={12}>
                                    <TextField
                                        id="outlined-basic1"
                                        fullWidth
                                        label="Nom du Produit*"
                                        onChange={formik.handleChange}
                                        value={formik.values.productName}
                                    />
                                </Grid>
                                <Grid item xs={12}>
                                    <TextField
                                        id="outlined-basic2"
                                        fullWidth
                                        multiline
                                        rows={3}
                                        label="Description"
                                        onChange={formik.handleChange}
                                        defaultValue={formik.values.productDescription}
                                    />
                                </Grid>
                                <Grid item xs={12}>
                                    <TextField
                                        id="standard-select-currency"
                                        select
                                        label="Categorie du Produit*"
                                        value={formik.values.productCategory}
                                        fullWidth
                                        onChange={handleSelectChange}
                                    >
                                        {tags.map((name) => (
                                            <MenuItem value={name}>{name}</MenuItem>
                                        ))}
                                    </TextField>
                                </Grid>
                                <Grid item xs={12}>
                                    <TextField
                                        id="outlined-basic3"
                                        fullWidth
                                        label="Reférence*"
                                        onChange={formik.handleChange}
                                        value={formik.values.productReference}
                                    />
                                </Grid>
                                <Grid item md={6} xs={12}>
                                    <TextField
                                        label="Prix*"
                                        id="filled-start-adornment1"
                                        onChange={formik.handleChange}
                                        value={formik.values.productPrice}
                                        defaultValue={formik.values.productPrice}
                                        InputProps={{ endAdornment: <InputAdornment position="start">€</InputAdornment> }}
                                    />
                                </Grid>
                                <Grid item md={6} xs={12}>
                                    <TextField
                                        label="Réduction"
                                        id="filled-start-adornment2"
                                        onChange={formik.handleChange}
                                        defaultValue={formik.values.productDiscount}
                                        InputProps={{ endAdornment: <InputAdornment position="start">%</InputAdornment> }}
                                    />
                                </Grid>
                                <Grid item md={6} xs={12}>
                                    <TextField
                                        label="Quantité*"
                                        id="quantity"
                                        defaultValue={formik.values.productQuantity}
                                        value={formik.values.productQuantity}
                                        onChange={formik.handleChange}
                                        placeholder="0"
                                    />
                                </Grid>
                                <Grid item md={6} xs={12}>
                                    <TextField
                                        label="Marque du produit*"
                                        id="brand"
                                        defaultValue={formik.values.productBrand}
                                        onChange={formik.handleChange}
                                        placeholder="Ex : Apple"
                                    />
                                </Grid>
                                <Grid item md={6} xs={12}>
                                    <TextField
                                        defaultValue={formik.values.productWeight}
                                        onChange={formik.handleChange}
                                        label="Poids"
                                        InputProps={{ endAdornment: <InputAdornment position="end">kg</InputAdornment> }}
                                    />
                                </Grid>
                                <Grid item xs={12}>
                                    <Grid container spacing={1}>
                                        <Grid item xs={12}>
                                            <Typography variant="subtitle1" align="left">
                                                Images du Produit*
                                            </Typography>
                                        </Grid>
                                        <Grid item xs={12}>
                                            <div>
                                                <TextField
                                                    type="file"
                                                    id="file-upload"
                                                    fullWidth
                                                    label="Enter SKU"
                                                    sx={{ display: 'none' }}
                                                />
                                                <InputLabel
                                                    htmlFor="file-upload"
                                                    sx={{
                                                        background: theme.palette.background.default,
                                                        py: 3.75,
                                                        px: 0,
                                                        textAlign: 'center',
                                                        borderRadius: '4px',
                                                        cursor: 'pointer',
                                                        mb: 3,
                                                        '& > svg': {
                                                            verticalAlign: 'sub',
                                                            mr: 0.5
                                                        }
                                                    }}
                                                >
                                                    <CloudUploadIcon /> Déposer vos images
                                                </InputLabel>
                                            </div>
                                        </Grid>
                                    </Grid>
                                </Grid>
                            </Grid>
                        </DialogContent>
                        <DialogActions>
                            <Button variant="text" color="error" onClick={handleCloseDialog}>
                                Fermer
                            </Button>
                            <AnimateButton>
                                <Button variant="contained" type="submit">
                                    Modifier
                                </Button>
                            </AnimateButton>
                        </DialogActions>
                    </form>
                </>
            )}
        </Dialog>
    );
};

ProductEdit.propTypes = {
    open: PropTypes.bool,
    handleCloseDialog: PropTypes.func
};

export default ProductEdit;
